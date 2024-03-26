{ self, config, pkgs, lib, ... }: {
  #imports = [ self.nixosModules.services.hysteria ];

  # networking.useNetworkd = lib.mkForce false;
  # networking.useDHCP = lib.mkForce true;

  # networking.firewall.enable = lib.mkForce true;
  # networking.nftables.enable = lib.mkForce false;
}
