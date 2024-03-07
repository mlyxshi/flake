{ pkgs, lib, ... }:
{
  home.stateVersion = "24.05";

  home.file.".config/helix".source = ../config/helix;
  home.file.".config/git".source = ../config/git;
  home.file.".config/joshuto".source = ../config/joshuto;

  news.display = "silent";
  news.json = lib.mkForce { };
  news.entries = lib.mkForce [ ];
}
