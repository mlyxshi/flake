{ pkgs, lib, ... }:
let
  mpv-scripts = pkgs.symlinkJoin {
    name = "mpv-scripts";
    paths = with pkgs;[
      mpvScripts.autoload
      mpvScripts.mpv-playlistmanager
    ];
  };
in
{
  home.file.".config/mpv" = {
    source = ../config/mpv;
    recursive = true;
  };

  home.file.".config/mpv/scripts".source = "${mpv-scripts}/share/mpv/scripts";
}
