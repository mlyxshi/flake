{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.shadowsocks
    self.nixosModules.services.libreddit
    self.nixosModules.services.invidious
  ];
}
