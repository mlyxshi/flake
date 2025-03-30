{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.tftp
    self.nixosModules.services.hysteria
    self.nixosModules.services.beszel-hub

    self.nixosModules.containers.podman
  ];
}
