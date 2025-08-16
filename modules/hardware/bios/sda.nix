{ modulesPath, pkgs, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;

  boot.loader.limine.enable = true;
  boot.loader.limine.biosSupport = true;
  boot.loader.limine.efiSupport = false;
  boot.loader.limine.biosDevice = "/dev/sda1";
  boot.loader.limine.maxGenerations = 3;

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

}
