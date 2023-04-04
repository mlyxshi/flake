{ config, pkgs, lib, ... }: {

  imports = [
    ./base.nix
  ];

  documentation = {
    doc.enable = false;
    enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };
}
