{ pkgs, lib, config, ... }: {
  home.file.".config/kitty".source = ../config/kitty;
}
