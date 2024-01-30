{ pkgs, lib, config, self, ... }: {

  imports = [
    ./desktop.nix
    ./fish.nix
  ];

  home = {
    username = "deck";
    homeDirectory = "/home/deck";
  };

  programs.firefox.package = lib.mkForce pkgs.firefox;

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };

}
