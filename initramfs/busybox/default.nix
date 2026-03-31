{
  pkgs ? import <nixpkgs> {
    system = "aarch64-linux";
  },
  pkgs-macos ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
rec {

  inherit (pkgs)
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

  kernel = pkgs.linuxPackages.kernel;

  # only run in qemu/cloud vps, so firmware is not required
  dummy-firmware = stdenvNoCC.mkDerivation {
    name = "dummy-firmware";
    buildCommand = "mkdir -p $out/lib/firmware";
  };

  modulesClosure = pkgs.makeModulesClosure {
    kernel = lib.getOutput "modules" kernel;
    rootModules = [
      # copy from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/profiles/qemu-guest.nix
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"

      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
      "virtio_gpu"

      "af_packet"
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

  bin = pkgs.buildEnv {
    name = "bin";
    paths = [
      tinyssh
      kmod
      busybox # https://github.com/NixOS/nixpkgs/blob/8110df5ad7abf5d4c0f6fb0f8f978390e77f9685/pkgs/os-specific/linux/busybox/default.nix#L198
    ];
    pathsToLink = [
      "/bin"
    ];
    # add extraBin
    postBuild = ''
      # ln -sf ${pkgs.curl}/bin/curl $out/bin/curl
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
        source = "${busybox}/default.script";  # default udhcpc script
      }
    ];

    buildCommand = ''
      make-initrd-ng <(echo "$contentsJSON") ./root
      mkdir "$out"
      (cd root && find . -exec touch -h -d '@1' '{}' +)
      (cd root && find . -print0 | sort -z | cpio --quiet -o -H newc -R +0:+0 --reproducible --null | zstd -10 >> "$out/initrd")
    '';
  };

  test = pkgs-macos.writeShellScriptBin "aarch64-initramfs-test" ''
    ls -lh ${initrd}/initrd | awk '{print $5}'
    /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 1G \
      -kernel ${kernel}/Image \
      -initrd ${initrd}/initrd \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=../../test/disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0"
  '';
}
