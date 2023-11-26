{
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "ext4";
  };

}
