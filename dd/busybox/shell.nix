{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [     
    gcc
    gnumake

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
