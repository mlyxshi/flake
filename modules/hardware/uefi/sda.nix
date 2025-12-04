{
  modulesPath,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.netbootxyz.enable = true; # emergency rescue on oracle arm

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "ext4";
    autoResize = true; # resizes filesystem to occupy whole partition
  };

  boot.growPartition = true; # resizes partition to occupy whole disk

  system.build.raw = import "${pkgs.path}/nixos/lib/make-disk-image.nix" {
    inherit config lib pkgs;
    format = "raw";
    copyChannel = false;
    partitionTableType = "efi";
    bootSize = "256M";
    additionalSpace = "128M";
  };

}
