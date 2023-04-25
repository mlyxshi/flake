{ config, pkgs, lib, ... }: {

  imports = [
    ./base.nix
  ];

  fonts.fontconfig.enable = false;

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };
}
