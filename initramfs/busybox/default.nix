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
    pkgsStatic
    writeText
    musl
    ;

  kernel = stdenv.mkDerivation {
    name = "kernel";
    inherit (pkgs.linuxPackages_latest.kernel) src;
    # https://github.com/torvalds/linux/blob/master/usr/gen_init_cpio.c
    initrd_cpio_list = writeText "initrd_cpio_list" ''
      dir /dev 0755 0 0
      nod /dev/console 0600 0 0 c 5 1

      file /init ${./init} 0755 0 0
      dir /bin 0755 0 0
      file /bin/busybox ${busybox-small}/bin/busybox 0755 0 0
      file /bin/udhcpc-script.sh ${./udhcpc-script.sh} 0755 0 0
      file /bin/blkid ${blkid-small}/bin/blkid 0755 0 0
      file /bin/cloud-init-networkcfg ${cloud-init-networkcfg}/bin/cloud-init-networkcfg 0755 0 0
    '';
    nativeBuildInputs = with pkgs; [
      bison
      flex
      bc
      perl
      elfutils
    ];
    buildPhase = "make ${stdenv.hostPlatform.linux-kernel.target} -j$NIX_BUILD_CORES";
    # https://kernel.org/doc/Documentation/kbuild/kconfig.txt
    configurePhase = ''
      make ARCH=${stdenv.hostPlatform.linuxArch} KCONFIG_ALLCONFIG=${./kernel.config} allnoconfig
      patchShebangs scripts/config && scripts/config --set-str INITRAMFS_SOURCE $initrd_cpio_list
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

  busybox-small = pkgsStatic.stdenv.mkDerivation {
    name = "busybox-small";
    inherit (pkgs.busybox) src;
    nativeBuildInputs = [ pkgs.stdenv.cc ]; # build kConfig
    buildInputs = [ pkgsStatic.stdenv.cc.libc ];
    configurePhase = ''
      source ${./busybox_merge_config.sh}
      make allnoconfig
      busybox_merge_config < ${./busybox.config}
    '';
    buildPhase = "make busybox -j$NIX_BUILD_CORES";
    installPhase = "install -Dm755 busybox $out/bin/busybox";
  };

  cloud-init-networkcfg = pkgsStatic.stdenv.mkDerivation {
    name = "cloud-init-networkcfg";
    src = ./cloud-init-networkcfg.c;
    dontUnpack = true;
    buildPhase = "$CC -s $src -o cloud-init-networkcfg";
    installPhase = "install -Dm755 cloud-init-networkcfg $out/bin/cloud-init-networkcfg";
  };

  blkid-small = pkgsStatic.stdenv.mkDerivation {
    name = "blkid-small";
    src = ./blkid-small.c;
    dontUnpack = true;
    buildPhase = "$CC -s $src -o blkid";
    installPhase = "install -Dm755 blkid $out/bin/blkid";
  };

  test-arm64 = pkgs-macos.writeShellScriptBin "aarch64-initramfs-test" ''
    ls -lh ${kernel}/Image | awk '{print $5}'
    ls -lh ${busybox-small}/bin/busybox | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 1G \
      -kernel ${kernel}/Image -append "earlycon=pl011,mmio32,0x9000000"\
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:23333" \
      -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd) \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=/Users/dominic/flake/test/disk-scsi.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -device "virtio-blk-pci,drive=hd0" -drive "file=/Users/dominic/flake/test/disk-blk.img,if=none,format=qcow2,id=hd0"
  '';

  test-x86-64 = pkgs-macos.writeShellScriptBin "x86-64-initramfs-test" ''
    ls -lh ${kernel}/bzImage  | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-x86_64 -cpu qemu64 -nographic -m 1G \
      -kernel ${kernel}/bzImage \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:23333" \
      -append "console=ttyS0" \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=/Users/dominic/flake/test/disk-scsi.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -device "virtio-blk-pci,drive=hd0" -drive "file=/Users/dominic/flake/test/disk-blk.img,if=none,format=qcow2,id=hd0"
  '';

  test = if stdenv.hostPlatform.system == "x86_64-linux" then test-x86-64 else test-arm64;
}
