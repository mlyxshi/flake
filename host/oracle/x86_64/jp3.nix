{ self, pkgs, lib, config, ... }: {
  imports = [ 
    self.nixosModules.services.hydra.x86_64 
    
    self.nixosModules.containers.podman
    self.nixosModules.containers.nodestatus-server
    self.nixosModules.containers.vaultwarden
  ];
}

