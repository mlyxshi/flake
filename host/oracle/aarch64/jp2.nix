{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.shadowsocks
    self.nixosModules.services.tftpd
  ];
}
