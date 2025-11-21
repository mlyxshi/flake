{ modulesPath, pkgs, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.systemd.enable = true;

  boot.loader.limine.enable = true;
  boot.loader.limine.biosSupport = true;
  boot.loader.limine.efiSupport = false;
  boot.loader.limine.biosDevice = "/dev/vda";
  boot.loader.limine.maxGenerations = 2;

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };
}
