{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.transmission
    self.nixosModules.containers.navidrome
  ];
}
