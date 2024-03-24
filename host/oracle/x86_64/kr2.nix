{ self, pkgs, lib, config,vpnconfinement, ... }: {
  imports = [ 
    self.nixosModules.services.hydra.x86_64 
  ];
}
