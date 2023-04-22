{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.container.podman
    self.nixosModules.container.change-detection
    self.nixosModules.container.rsshub
  ];
}
