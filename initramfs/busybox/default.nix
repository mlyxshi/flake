{
  pkgs ? import <nixpkgs> {
    system = "aarch64-linux";
    # system = "x86_64-linux";
  },
  pkgs-macos ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
rec {

  inherit (pkgs)
    stdenv
    stdenvNoCC
    pkgsMusl
    ;

  kernel = stdenv.mkDerivation {
    enableParallelBuilding = true;
    name = "kernel";
    inherit (pkgs.linuxPackages_latest.kernel) src;
    nativeBuildInputs = with pkgs; [
      bison
      flex
      bc
      perl
      elfutils
    ];
    configurePhase = ''
      make ARCH=${stdenv.hostPlatform.linuxArch} allnoconfig
      ./scripts/kconfig/merge_config.sh -m .config  ${./kernel.config}
      make ARCH=${stdenv.hostPlatform.linuxArch} olddefconfig
    '';
    installPhase = ''
      mkdir -p $out
      if [ "${stdenv.hostPlatform.linuxArch}" = "arm64" ]; then
        cp arch/arm64/boot/Image $out
      else
        cp arch/x86/boot/bzImage $out
      fi
    '';
  };

  busybox_merge_config = stdenvNoCC.mkDerivation {
    name = "merge_config";
    buildCommand = ''
      cat ${./busybox_merge_config.sh} > $out
      chmod +x $out
    '';
  };

  busybox-small = pkgsMusl.stdenv.mkDerivation {
    enableParallelBuilding = true;
    name = "busybox-small";
    inherit (pkgs.busybox) src;
    configurePhase = ''
      make allnoconfig
      printf 'CONFIG_PREFIX "%s"\n' $out | ${busybox_merge_config}
      ${busybox_merge_config} < ${./busybox.config}
    '';
  };

  tinyssh-small = pkgsMusl.stdenv.mkDerivation {
    enableParallelBuilding = true;
    name = "tinyssh-small";
    inherit (pkgs.tinyssh) src;
    installPhase = ''
      mkdir -p $out/bin
      cp tinysshd $out/bin/
      ln -s tinysshd $out/bin/tinysshd-makekey
    '';
  };

  init = stdenvNoCC.mkDerivation {
    name = "init";
    buildCommand = ''
      cat ${./init} > $out
      chmod +x $out
    '';
  };

  udhcpc-script = stdenvNoCC.mkDerivation {
    name = "udhcpc-script";
    buildCommand = ''
      cat ${./udhcpc.sh} > $out
      chmod +x $out
    '';
  };

  cloud-init-networkcfg = pkgsMusl.stdenv.mkDerivation {
    name = "cloud-init-networkcfg";
    dontUnpack = true;
    installPhase = ''
      gcc ${./cloud-init-networkcfg.c} -o cloud-init-networkcfg
      mkdir -p $out/bin
      cp cloud-init-networkcfg $out/bin
    '';
  };

  blkid-small = pkgsMusl.stdenv.mkDerivation {
    name = "blkid-small";
    dontUnpack = true;
    installPhase = ''
      gcc ${./blkid-small.c} -o blkid
      mkdir -p $out/bin
      cp blkid $out/bin
    '';
  };

  bin = pkgs.buildEnv {
    name = "bin";
    paths = [
      tinyssh-small
      blkid-small
      busybox-small
      cloud-init-networkcfg
    ];
    pathsToLink = [
      "/bin"
    ];
  };

  initrd = stdenvNoCC.mkDerivation {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;

    name = "initrd";
    nativeBuildInputs = with pkgs;[
      makeInitrdNGTool
      cpio
    ];

    contentsJSON = builtins.toJSON [
      {
        source = init;
        target = "/init";
      }
      {
        source = "${bin}/bin";
        target = "/bin";
      }
      {
        source = udhcpc-script;
        target = "/udhcpc.sh";
      }
    ];

    buildCommand = ''
      make-initrd-ng <(echo "$contentsJSON") ./root
      mkdir "$out"
      (cd root && find . -exec touch -h -d '@1' '{}' +)
      (cd root && find . -print0 | sort -z | cpio --quiet -o -H newc -R +0:+0 --reproducible --null  >> "$out/initrd")
    '';
  };

  test-arm64 = pkgs-macos.writeShellScriptBin "aarch64-initramfs-test" ''
    ls -lh ${kernel}/Image | awk '{print $5}'
    ls -lh ${initrd}/initrd | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 1G \
      -kernel ${kernel}/Image -append "earlycon=pl011,mmio32,0x9000000"\
      -initrd ${initrd}/initrd \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
      -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd) \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=/Users/dominic/flake/test/disk-scsi.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -device "virtio-blk-pci,drive=hd0" -drive "file=/Users/dominic/flake/test/disk-blk.img,if=none,format=qcow2,id=hd0"
  '';

  test-x86-64 = pkgs-macos.writeShellScriptBin "x86-64-initramfs-test" ''
    ls -lh ${kernel}/bzImage  | awk '{print $5}'
    ls -lh ${initrd}/initrd | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-x86_64 -cpu qemu64 -nographic -m 1G \
      -kernel ${kernel}/bzImage \
      -initrd ${initrd}/initrd \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
      -append "console=ttyS0" \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=/Users/dominic/flake/test/disk-scsi.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -device "virtio-blk-pci,drive=hd0" -drive "file=/Users/dominic/flake/test/disk-blk.img,if=none,format=qcow2,id=hd0"
  '';

  test = if stdenv.hostPlatform.system == "x86_64-linux" then test-x86-64 else test-arm64;
}
