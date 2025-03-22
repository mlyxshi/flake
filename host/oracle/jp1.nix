{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.tftp
    self.nixosModules.services.hysteria
    self.nixosModules.services.beszel-hub
  ];

  services.uptime-kuma.enable = true;
}
