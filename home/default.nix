{ pkgs, lib, config, ... }: {

  home.stateVersion = "24.05";

  home.file.".config/joshuto".source = ../config/joshuto;
  home.file.".config/helix".source = ../config/helix;
  home.file.".config/git".source = ../config/git;
}
