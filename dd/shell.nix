# nix develop -f /flake/dd/shell.nix 
{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [     
    gcc
    gnumake
    pkg-config

    # configure
    flex
    bison

    # build
    bc
  ];

  buildInputs = with pkgs;[
    # make menuconfig
    ncurses
  ];
}
