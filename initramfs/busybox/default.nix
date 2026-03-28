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
    ;

  kernel = pkgs.linuxPackages.kernel;

  # For qemu guest, firmware is not necessary
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
      "9p"
      "9pnet_virtio"

      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
      "virtio_gpu"

      "ext4"

      "vfat"
      "nls_cp437"
      "nls_iso8859-1"

      "iso9660" # cloud-init cidata disk
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
        source = "${modulesClosure}/lib";
        target = "/lib";
      }
      {
        source = "${busybox}/bin";
        target = "/bin";
      }
      {
        source = init;
        target = "/init";
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
    /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 4G \
      -kernel ${kernel}/Image \
      -initrd ${initrd}/initrd \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=../test/disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd)
  '';
}
