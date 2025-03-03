{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.hysteria
    self.nixosModules.services.tftp
  ];
}
