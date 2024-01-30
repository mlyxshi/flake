{ pkgs, lib, config, self, ... }: {

  imports = [
    ./desktop.nix
    ./fish.nix
    ./common-package.nix
  ];

  home = {
    username = "deck";
    homeDirectory = "/home/deck";
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };

}
