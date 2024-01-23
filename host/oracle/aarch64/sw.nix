{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.containers.miniflux
  ];
}
