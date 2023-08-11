{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.hysteria
  ];

  networking.nftables.enable = lib.mkForce false;
}
