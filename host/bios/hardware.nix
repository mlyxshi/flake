{ modulesPath, pkgs, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";


  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/4148f2f1-30d7-41d3-8b69-37c0b0db93bb";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/acdb553b-71d4-43ea-b4bb-c5028f1b3454";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/FAC5-D5BF";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
}
