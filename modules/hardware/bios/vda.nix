{ modulesPath, pkgs, lib, config, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;

  boot.loader.limine.enable = true;
  boot.loader.limine.biosSupport = true;
  boot.loader.limine.efiSupport = false;
  boot.loader.limine.biosDevice = "/dev/vda";
  boot.loader.limine.maxGenerations = 2;
  boot.loader.timeout = 2;

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
    autoResize = true; # resizes filesystem to occupy whole partition
  };

  boot.growPartition = true; # resizes partition to occupy whole disk

  system.build.raw = import "${pkgs.path}/nixos/lib/make-disk-image.nix" {
    inherit config lib pkgs;
    format = "raw";
    copyChannel = false;
    partitionTableType = "legacy+boot"; # limine bootloader
    bootSize = "128M";
    additionalSpace = "128M";
  };
}
