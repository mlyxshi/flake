{ pkgs, lib, config, ... }: {
  imports = [
    ./git.nix
  ];

  home.stateVersion = "24.05";

  home.file.".config/joshuto".source = ../config/joshuto;
  home.file.".config/helix".source = ../config/helix;
}
