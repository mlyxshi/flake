{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.transmission

    self.nixosModules.containers.jellyfin
    self.nixosModules.containers.navidrome
    self.nixosModules.containers.change-detection
  ];

  networking.nftables.enable = lib.mkForce false;
}
