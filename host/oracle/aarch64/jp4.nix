{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.transmission

    self.nixosModules.containers.navidrome

    self.nixosModules.services.backup
    self.nixosModules.containers.jellyfin
    self.nixosModules.containers.change-detection

    self.nixosModules.containers.baidunetdisk
  ];

  networking.nftables.enable = lib.mkForce false;
}
