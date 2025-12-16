{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  boot.loader.grub.device = "nodev";

  fileSystems."/old-root" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [ "X-mount.subdir=new-root" ];
  };
  fileSystems."/nix" = {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [ "X-mount.subdir=nix" ];
  };

}
