{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.transmission
    
    self.nixosModules.container.podman
    self.nixosModules.container.jellyfin
    self.nixosModules.container.navidrome
  ];

  networking.nftables.enable = lib.mkForce false;
}
