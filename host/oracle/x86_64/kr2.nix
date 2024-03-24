{ self, pkgs, lib, config,vpnconfinement, ... }: {
  imports = [ 
    self.nixosModules.services.hydra.x86_64 
    vpnconfinement.nixosModules.default
  ];

  networking.firewall.enable = lib.mkForce true;
  networking.nftables.enable = lib.mkForce false;


  vpnnamespaces.wg = {
    enable = true;
    accessibleFrom = [ "192.168.0.0/24" ];
    wireguardConfigFile = "/tmp/wg0.conf";
  };


}
