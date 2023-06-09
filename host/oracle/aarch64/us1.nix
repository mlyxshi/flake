{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.hysteria
    self.nixosModules.services.libreddit
    self.nixosModules.services.invidious
  ];
}
