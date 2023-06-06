{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.tuic
    self.nixosModules.services.libreddit
    self.nixosModules.services.invidious
  ];
}
