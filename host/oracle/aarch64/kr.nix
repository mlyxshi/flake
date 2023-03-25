{ config, pkgs, lib, self, ... }: {
  imports = [
    self.nixosModules.services.hydra-aarch64
  ];

}
