{ config, pkgs, lib, ... }: {

  imports = [
    ./base.nix
  ];

  documentation.enable = false;
}
