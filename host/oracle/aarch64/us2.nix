{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.miniflux
    self.nixosModules.containers.rsshub
  ];
}
