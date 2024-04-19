{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.hydra.aarch64
  ];
}
