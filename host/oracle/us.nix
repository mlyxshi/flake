{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.hysteria
    self.nixosModules.services.transmission
  ];

  services.uptime-kuma.enable = true;
}
