{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
rec {

  inherit (pkgs)
    stdenvNoCC
    busybox
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

  initrd = pkgs.makeInitrdNG {
    compressor = "zstd";

    contents = [
      {
        source = "${modulesClosure}/lib";
        target = "/lib";
      }
      {
        source = "${busybox}/bin";
        target = "/bin";
      }
      {
        source = ./init;
        target = "/init";
      }
    ];
  };
}
