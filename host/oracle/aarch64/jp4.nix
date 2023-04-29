{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.transmission

    self.nixosModules.containers.podman
    self.nixosModules.containers.jellyfin
    self.nixosModules.containers.navidrome
  ];

  networking.nftables.enable = lib.mkForce false;
}
