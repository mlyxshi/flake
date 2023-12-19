{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.containers.nodestatus-server
    self.nixosModules.containers.matrix-viewer
  ];
}
