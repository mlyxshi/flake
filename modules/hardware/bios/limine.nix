{
  modulesPath,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  boot.loader.limine.enable = true;
  boot.loader.limine.biosSupport = true;
  boot.loader.limine.efiSupport = false;
  boot.loader.limine.biosDevice = lib.mkDefault "/dev/vda";
  boot.loader.limine.partitionIndex = 1; # GPT bios boot partition
  boot.loader.limine.maxGenerations = 2;
  boot.loader.timeout = 1;

  fileSystems."/boot" = {
    device = config.boot.loader.limine.biosDevice + "2";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = config.boot.loader.limine.biosDevice + "3";
    fsType = "ext4";
  };
}
