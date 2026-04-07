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
    pkgsStatic
    writeText
    musl
    ;

  kernel = stdenv.mkDerivation {
    enableParallelBuilding = true;
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

    configurePhase = ''
      make ARCH=${stdenv.hostPlatform.linuxArch} allnoconfig
      ./scripts/kconfig/merge_config.sh -m .config  ${./kernel.config} 
      ./scripts/kconfig/merge_config.sh -m .config <(printf 'CONFIG_INITRAMFS_SOURCE="%s"' $initrd_cpio_list)
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

  # Busybox uses a complex build system, copy ideas from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/busybox/default.nix
  busybox-small = stdenv.mkDerivation {
    enableParallelBuilding = true;
    name = "busybox-small";
    inherit (pkgs.busybox) src;
    nativeBuildInputs = [ stdenv.cc ];
    configurePhase = ''
      source ${./busybox_merge_config.sh}
      make allnoconfig
      printf "CONFIG_STATIC y" | busybox_merge_config
      busybox_merge_config < ${./busybox.config}
      runHook postConfigure
    '';
    postConfigure = ''
      makeFlagsArray+=("CC=cc -isystem ${musl.dev}/include -B${musl}/lib -L${musl}/lib")
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp busybox $out/bin
    '';
  };

  cloud-init-networkcfg = pkgsStatic.stdenv.mkDerivation {
    name = "cloud-init-networkcfg";
    dontUnpack = true;
    installPhase = ''
      $CC -s ${./cloud-init-networkcfg.c} -o cloud-init-networkcfg
      mkdir -p $out/bin
      cp cloud-init-networkcfg $out/bin
    '';
  };

  blkid-small = pkgsStatic.stdenv.mkDerivation {
    name = "blkid-small";
    dontUnpack = true;
    installPhase = ''
      $CC -s ${./blkid-small.c} -o blkid
      mkdir -p $out/bin
      cp blkid $out/bin
    '';
  };

  test-arm64 = pkgs-macos.writeShellScriptBin "aarch64-initramfs-test" ''
    ls -lh ${kernel}/Image | awk '{print $5}'
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
