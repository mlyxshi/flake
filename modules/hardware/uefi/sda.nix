{
  modulesPath,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-partlabel/nixos";
      fsType = "ext4";
    };
  };
}
