{ config, lib, pkgs, ... }: {

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partlabel/BOOT";
      fsType = "vfat";
    };
    "/" = {
      fsType = "tmpfs";
      options = [ "mode=755" ];
    };
    "/nix" = {
      device = "/dev/disk/by-partlabel/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" "compress-force=zstd" ];
    };
    "/persist" = {
      device = "/dev/disk/by-partlabel/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=persist" "noatime" "compress-force=zstd" ];
      neededForBoot = true;
    };
  };


  environment.persistence."/persist" = {
    directories = [
      "/root"
      "/var"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.dominic.directories = [
      # ".cache/mozilla"
    ];
  };


}
