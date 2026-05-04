# musl dynamic link

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
    pkgsStatic
    musl
    fetchFromGitHub
    ;

  kernel = stdenv.mkDerivation {
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
      make ARCH=${stdenv.hostPlatform.linuxArch} KCONFIG_ALLCONFIG=${./kernel.config} allnoconfig
    '';
    buildPhase = "make ${stdenv.hostPlatform.linux-kernel.target} -j$NIX_BUILD_CORES";
    installPhase = ''
      mkdir -p $out
      if [ "${stdenv.hostPlatform.linuxArch}" = "arm64" ]; then
        cp arch/arm64/boot/Image $out
      else
        cp arch/x86/boot/bzImage $out
      fi
    '';
  };

  # substituteInPlace kconfig/Makefile  --replace-fail '-lcurses' '-lncurses'
  # patchShebangs .
  toybox = pkgsStatic.stdenv.mkDerivation {
    name = "toybox";
    src = fetchFromGitHub {
      owner = "landley";
      repo = "toybox";
      rev = "a0206a4dce5d296514b5725b0288467c98a6ce3c";
      hash = "sha256-HG97s54xmCbHPSoo8pOYy71UEkGNFwX8HbrKrF78Hck=";
    };
    hardeningDisable = [ "fortify" ]; # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/to/toybox/package.nix
    configurePhase = ''
      patchShebangs .
      make HOSTCC=$CC KCONFIG_ALLCONFIG=${./toybox.config} allnoconfig
    '';
    buildPhase = "make HOSTCC=$CC toybox -j$NIX_BUILD_CORES";
    installPhase = "install -Dm755 toybox $out/bin/toybox";
  };

  init = stdenvNoCC.mkDerivation {
    name = "init";
    buildCommand = ''
      cat ${./init} > $out
      chmod +x $out
    '';
  };

  cloud-init-networkcfg = pkgsMusl.stdenv.mkDerivation {
    name = "cloud-init-networkcfg";
    src = ./cloud-init-networkcfg.c;
    dontUnpack = true;
    buildPhase = "$CC -s $src -o cloud-init-networkcfg";
    installPhase = "install -Dm755 cloud-init-networkcfg $out/bin/cloud-init-networkcfg";
  };

  bin = pkgs.buildEnv {
    name = "bin";
    paths = [
      toybox
      cloud-init-networkcfg
    ];
    pathsToLink = [
      "/bin"
    ];
    postBuild = ''
      cat ${./udhcpc-script.sh} > $out/bin/udhcpc-script.sh
      chmod +x $out/bin/udhcpc-script.sh
    '';
  };

  initrd = stdenvNoCC.mkDerivation {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;

    name = "initrd";
    nativeBuildInputs = with pkgs; [
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
    ];

    buildCommand = ''
      mkdir $out
      make-initrd-ng <(echo "$contentsJSON") ./root
      cd root
      find . -exec touch -h -d '@1' '{}' +
      find . -print0 | sort -z | cpio --quiet -o -H newc -R +0:+0 --reproducible --null > $out/initrd
    '';
  };

  initrd-kernel = stdenv.mkDerivation {
    name = "initrd";
    inherit (pkgs.linuxPackages_latest.kernel) src;
    # https://github.com/torvalds/linux/blob/master/usr/gen_init_cpio.c
    initrd_cpio_list = pkgs.writeText "initrd_cpio_list" ''
      dir /dev 0755 0 0
      nod /dev/console 0600 0 0 c 5 1
      dir /bin 0755 0 0
      file /init ${./init} 0755 0 0
    '';
    buildCommand = ''
      runPhase unpackPhase
      $CC ./usr/gen_init_cpio.c -o ./usr/gen_init_cpio
      mkdir $out
      ./usr/gen_init_cpio $initrd_cpio_list > $out/initrd.cpio
    '';
  };

  test-arm64 = pkgs-macos.writeShellScriptBin "aarch64-initramfs-test" ''
    ls -lh ${kernel}/Image | awk '{print $5}'
    ls -lh ${initrd}/initrd | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 1G \
      -kernel ${kernel}/Image -append "earlycon=pl011,mmio32,0x9000000"\
      -initrd ${initrd}/initrd \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:23333" \
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
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:23333" \
      -append "console=ttyS0" \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=/Users/dominic/flake/test/disk-scsi.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -device "virtio-blk-pci,drive=hd0" -drive "file=/Users/dominic/flake/test/disk-blk.img,if=none,format=qcow2,id=hd0"
  '';

  test = if stdenv.hostPlatform.system == "x86_64-linux" then test-x86-64 else test-arm64;
}
