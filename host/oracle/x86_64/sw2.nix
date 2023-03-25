{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.container.podman
    self.nixosModules.container.nodestatus-server
  ];
}
