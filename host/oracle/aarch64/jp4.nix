{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.transmission
  ];

  networking.nftables.enable = lib.mkForce false;
}
