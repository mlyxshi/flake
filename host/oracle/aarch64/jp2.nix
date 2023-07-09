{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.hysteria
    self.nixosModules.services.snell
    self.nixosModules.services.tuic
    self.nixosModules.services.tftpd
  ];
}
