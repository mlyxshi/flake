{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.transmission
  ];

  networking.nftables.enable = lib.mkForce false;
}
