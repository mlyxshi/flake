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
    ;

  kernel = stdenv.mkDerivation (finalAttrs: {
    name = "kernel";
    inherit (pkgs.linuxPackages_latest.kernel) src;
    # https://github.com/torvalds/linux/blob/master/usr/gen_init_cpio.c
    initrd_cpio_list = writeText "initrd_cpio_list" ''
      dir /dev 0755 0 0
      nod /dev/console 0600 0 0 c 5 1

      file /init ${./init} 0755 0 0
      dir /bin 0755 0 0
      file /bin/busybox ${busybox}/bin/busybox 0755 0 0
      file /bin/udhcpc-script.sh ${./udhcpc-script.sh} 0755 0 0
      file /bin/cloud-init-networkcfg ${cloud-init-networkcfg}/bin/cloud-init-networkcfg 0755 0 0
    '';
    kernel_config = writeText "kernel_config" ''
      ${builtins.readFile ./kernel.config}
      CONFIG_INITRAMFS_SOURCE="${finalAttrs.initrd_cpio_list}"
    '';
    nativeBuildInputs = with pkgs; [
      bison
      flex
      bc
      perl
      elfutils
    ];
    # https://kernel.org/doc/Documentation/kbuild/kconfig.txt
    configurePhase = "make ARCH=${stdenv.hostPlatform.linuxArch} KCONFIG_ALLCONFIG=${finalAttrs.kernel_config} allnoconfig";
    buildPhase = "make ${stdenv.hostPlatform.linux-kernel.target} -j$NIX_BUILD_CORES";
    installPhase = ''
      mkdir -p $out
      cp arch/${if stdenv.hostPlatform.isAarch64 then "arm64/boot/Image" else "x86/boot/bzImage"} $out
    '';
  });

  busybox = pkgsStatic.stdenv.mkDerivation {
    name = "busybox";
    inherit (pkgs.busybox) src;
    # https://bugs.busybox.net/show_bug.cgi?id=10296
    # https://github.com/mirror/busybox/commits/master/scripts/kconfig/conf.c
    oldConf = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/mirror/busybox/fcbc641fe36a2ceff334362cc6ba62b000c842a5/scripts/kconfig/conf.c";
      hash = "sha256-veFFCU3brzLrJ6myfW9XYPIGYLWv4/HfJsfmySb3Tec=";
    };
    configurePhase = ''
      cp $oldConf scripts/kconfig/conf.c
      make HOSTCC=$CC KCONFIG_ALLCONFIG=${./busybox.config} allnoconfig
    '';
    buildPhase = "make HOSTCC=$CC CROSS_COMPILE=${pkgsStatic.stdenv.cc.targetPrefix}  busybox -j$NIX_BUILD_CORES";
    installPhase = "install -Dm755 busybox $out/bin/busybox";
  };

  cloud-init-networkcfg = pkgsStatic.runCommandCC "cloud-init-networkcfg" { } ''
    mkdir -p $out/bin
    $CC -static -s ${./cloud-init-networkcfg.c} -o $out/bin/cloud-init-networkcfg
  '';

  test-arm64 = pkgs-macos.writeShellScriptBin "aarch64-initramfs-test" ''
    ls -lh ${kernel}/Image | awk '{print $5}'
    ls -lh ${busybox}/bin/busybox | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 256M \
      -kernel ${kernel}/Image -append "earlycon=pl011,mmio32,0x9000000"\
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:23333" \
      -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd) \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=/Users/dominic/flake/test/disk-scsi.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -device "virtio-blk-pci,drive=hd0" -drive "file=/Users/dominic/flake/test/disk-blk.img,if=none,format=qcow2,id=hd0"
  '';

  test-x86-64 = pkgs-macos.writeShellScriptBin "x86-64-initramfs-test" ''
    ls -lh ${kernel}/bzImage  | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-x86_64 -cpu qemu64 -nographic -m 256M \
      -kernel ${kernel}/bzImage \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:23333" \
      -append "console=ttyS0" \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=/Users/dominic/flake/test/disk-scsi.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -device "virtio-blk-pci,drive=hd0" -drive "file=/Users/dominic/flake/test/disk-blk.img,if=none,format=qcow2,id=hd0"
  '';

  test = if stdenv.hostPlatform.system == "x86_64-linux" then test-x86-64 else test-arm64;
}
