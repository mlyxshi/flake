{ self, config, pkgs, lib, ... }: {
  #imports = [ self.nixosModules.services.hysteria ];

  # I don't know why oracle ipv6 is not working under systemd-networkd
  # so use default old way to configure network 
  networking.useNetworkd = lib.mkForce false;
  networking.useDHCP = lib.mkForce true;

  networking.firewall.enable = lib.mkForce true;
  networking.nftables.enable = lib.mkForce false;
  networking.firewall.allowedTCPPorts = [ 443 80 ];

  


}
