{ pkgs, lib, config, self, ... }: {

  imports = [ ./desktop.nix ./fish.nix ./common-package.nix ];

  home = {
    username = "dominic";
    homeDirectory = "/home/dominic";
  };

  programs.firefox.package = null;
}
