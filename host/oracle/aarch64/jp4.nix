{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.qbittorrent
    self.nixosModules.services.alist
  ];
}
