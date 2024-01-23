{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.containers.miniflux
    self.nixosModules.containers.rsshub
  ];
}
