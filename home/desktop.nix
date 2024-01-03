{ pkgs, lib, config, ... }: {

  imports = [
    ./default.nix
    ./firefox
  ];
}