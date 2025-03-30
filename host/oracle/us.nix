{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.hysteria
    self.nixosModules.services.transmission
    self.nixosModules.services.snell
    self.nixosModules.containers.podman
  ];
}
