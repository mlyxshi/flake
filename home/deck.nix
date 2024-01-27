{ pkgs, lib, config, self, ... }: {

  imports = [
    ./desktop.nix
    ./fish.nix
  ];

  home = {
    username = "deck";
    homeDirectory = "/home/deck";
  };

}
