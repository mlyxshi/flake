{
  pkgs ? import <nixpkgs> {
    # system = "aarch64-linux";
    system = "x86_64-linux";
  },
  pkgs-macos ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
rec {

  inherit (pkgs)
    stdenv
    stdenvNoCC
    busybox
    makeInitrdNGTool
    cpio
    zstd
    systemd
    kmod
    tinyssh
    writeText
    ;

  kernel = pkgs.linuxPackages_latest.kernel;

  # only run in qemu/cloud vps, so firmware is not required
  dummy-firmware = stdenvNoCC.mkDerivation {
    name = "dummy-firmware";
    buildCommand = "mkdir -p $out/lib/firmware";
  };

  modulesClosure = pkgs.makeModulesClosure {
    kernel = lib.getOutput "modules" kernel;
    rootModules = [
      "virtio_pci"

      # Network
      "virtio_net"
      "af_packet"

      # Disk
      "virtio_scsi" # Virtio SCSI controller  # -device virtio-scsi-pci  (/dev/sdX)
      "sd_mod" # SCSI disk driver # -device scsi-hd

      "virtio_blk" # -device virtio-blk-pci (/dev/vdX)

      "ahci" # SATA controllers
      "sr_mod" # SCSI CD-ROM driver (/dev/srX) cloud-init cidata disk
      "isofs" # mount /dev/sr1 /cloud-init
    ];
    firmware = dummy-firmware;
  };

  init = stdenvNoCC.mkDerivation {
    name = "init";
    buildCommand = ''
      cat ${./init} > $out
      chmod +x $out
    '';
  };

  cloud-init-networkcfg = stdenv.mkDerivation {
    name = "cloud-init-networkcfg";
    dontUnpack = true;
    installPhase = ''
      gcc ${./cloud-init-networkcfg.c} -o cloud-init-networkcfg
      mkdir -p $out/bin
      cp cloud-init-networkcfg $out/bin
    '';
  };

  bin = pkgs.buildEnv {
    name = "bin";
    paths = [
      tinyssh
      kmod
      busybox # https://github.com/NixOS/nixpkgs/blob/8110df5ad7abf5d4c0f6fb0f8f978390e77f9685/pkgs/os-specific/linux/busybox/default.nix#L198
      cloud-init-networkcfg
    ];
    pathsToLink = [
      "/bin"
    ];
    # add extraBin
    postBuild = ''
      ln -sf ${pkgs.util-linux}/bin/lsblk $out/bin/lsblk
      ln -sf ${pkgs.util-linux}/bin/blkid $out/bin/blkid
    '';
  };

  initrd = stdenvNoCC.mkDerivation {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;

    name = "initrd";
    nativeBuildInputs = [
      makeInitrdNGTool
      cpio
      zstd
    ];

    contentsJSON = builtins.toJSON [
      {
        source = init;
        target = "/init";
      }
      {
        source = "${modulesClosure}/lib";
        target = "/lib";
      }
      {
        source = "${bin}/bin";
        target = "/bin";
      }
      {
        source = "${busybox}/default.script"; # default udhcpc script
      }
    ];

    buildCommand = ''
      make-initrd-ng <(echo "$contentsJSON") ./root
      mkdir "$out"
      (cd root && find . -exec touch -h -d '@1' '{}' +)
      (cd root && find . -print0 | sort -z | cpio --quiet -o -H newc -R +0:+0 --reproducible --null | zstd -10 >> "$out/initrd")
    '';
  };

  test-arm = pkgs-macos.writeShellScriptBin "aarch64-initramfs-test" ''
    ls -lh ${initrd}/initrd | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 1G \
      -kernel ${kernel}/Image \
      -initrd ${initrd}/initrd \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=../../test/disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0"
  '';

  test = pkgs-macos.writeShellScriptBin "x86-64-initramfs-test" ''
    ls -lh ${initrd}/initrd | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-x86_64 -cpu qemu64 -nographic -m 1G \
      -kernel ${kernel}/bzImage \
      -initrd ${initrd}/initrd \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=../../test/disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -append "console=ttyS0,115200"
  '';
}
