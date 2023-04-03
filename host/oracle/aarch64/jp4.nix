{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.shadowsocks
    self.nixosModules.services.qbittorrent
  ];
}
