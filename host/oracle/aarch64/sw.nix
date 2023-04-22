{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.container.podman
    self.nixosModules.container.rsshub

    self.nixosModules.services.change-detection
  ];
}
