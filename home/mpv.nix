{ pkgs, lib, config, ... }: {
  programs.mpv = {
    enable = true;
    # Install mpv from Homebrew on macOS
    package =
      if pkgs.stdenv.isLinux
      then # Linux
        pkgs.mpv
      else # Darwin
        pkgs.runCommand "mpv-0.0.0" { } "mkdir $out";

    bindings =
      {
        # https://github.com/mpv-player/mpv/blob/master/etc/input.conf
        h = "add sub-pos -1";
        H = "add sub-pos +1";
        "[" = "add speed -0.1";
        "]" = "add speed +0.1";
        "{" = "add speed -0.5";
        "}" = "add speed +0.5";
      };
  };

  home.packages = with pkgs; [
    ffmpeg
    yt-dlp
    mediainfo
  ];

  home.file.".config/mpv/mpv.conf".source =
    if pkgs.stdenv.isLinux
    then ../config/mpv/mpv-linux.conf
    else ../config/mpv/mpv-darwin.conf;
  home.file.".config/mpv/scripts".source = ../config/mpv/scripts;
  home.file.".config/mpv/script-opts".source = ../config/mpv/script-opts;
}
