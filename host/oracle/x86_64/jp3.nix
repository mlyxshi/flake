{ self, pkgs, lib, config, ... }: {
  imports = [ 
    self.nixosModules.containers.podman
    self.nixosModules.containers.nodestatus-server
  ];
}

