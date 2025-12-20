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

  boot.loader.grub.device = "/dev/vda";

  fileSystems."/" = {
    device = config.boot.loader.grub.device + "1";
    fsType = "ext4";
  };
}
