{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.tuic
    self.nixosModules.services.tftpd
  ];
}
