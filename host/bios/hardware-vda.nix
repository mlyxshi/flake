{ modulesPath, pkgs, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

}
