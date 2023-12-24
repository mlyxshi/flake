{
  imports = [ ./common.nix ];

  home.file.".config/helix".source = ../config/helix;
  home.file.".config/git".source = ../config/git;
  home.file.".config/joshuto".source = ../config/joshuto;
}
