{
  imports = [ ./common.nix ];

  home.file.".config/helix".source = ../config/.config/helix;
  home.file.".config/git".source = ../config/.config/git;
  home.file.".config/joshuto".source = ../config/.config/joshuto;
}
