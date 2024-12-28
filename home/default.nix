{ pkgs, lib, ... }: {
  home.stateVersion = "24.11";

  home.file.".config/helix".source = ../config/helix;
  home.file.".config/git".source = ../config/git;
  home.file.".config/yazi".source = ../config/yazi;

  news.display = "silent";
  news.json = lib.mkForce { };
  news.entries = lib.mkForce [ ];
}
