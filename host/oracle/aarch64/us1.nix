{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.hysteria
    self.nixosModules.services.tuic
  ];

  networking.nftables.enable = lib.mkForce false;
}
