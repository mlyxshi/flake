{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.tftp
    self.nixosModules.services.snell
    self.nixosModules.services.beszel-hub
  ];
}
