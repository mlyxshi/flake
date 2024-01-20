{ pkgs, lib, ... }: {
  home.stateVersion = "24.05";

  home.file.".config/helix".source = ../config/.config/helix;
  home.file.".config/git".source = ../config/.config/git;
  home.file.".config/joshuto".source = ../config/.config/joshuto;

  news.display = "silent";
  news.json = lib.mkForce { };
  news.entries = lib.mkForce [ ];
}
