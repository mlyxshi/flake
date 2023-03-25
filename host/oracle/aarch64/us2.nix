{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.miniflux
  ];
}
