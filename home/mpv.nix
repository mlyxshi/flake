{ pkgs, lib, config, osConfig, ... }:
let
  anime4k = pkgs.Anime4k;
  Anime4kInputs = {
    #lower-end GPU    <-- Apple M1
    "CTRL+1" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A (Fast)"'';
    "CTRL+2" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B (Fast)"'';
    "CTRL+3" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C (Fast)"'';
    "CTRL+4" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A+A (Fast)"'';
    "CTRL+5" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B+B (Fast)"'';
    "CTRL+6" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C+A (Fast)"'';
    "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
  };
in
{
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
      }
      // Anime4kInputs;
  };

  home.packages = with pkgs; [
    ffmpeg
    yt-dlp
    mediainfo
  ];

  home.file.".config/mpv/mpv.conf".source =
    if pkgs.stdenv.isLinux
    then config.lib.file.mkOutOfStoreSymlink "${osConfig.settings.nixConfigDir}/config/mpv/mpv-linux.conf"
    else config.lib.file.mkOutOfStoreSymlink "${osConfig.settings.nixConfigDir}/config/mpv/mpv-darwin.conf";
  home.file.".config/mpv/scripts".source = config.lib.file.mkOutOfStoreSymlink "${osConfig.settings.nixConfigDir}/config/mpv/scripts";
  home.file.".config/mpv/script-opts".source = config.lib.file.mkOutOfStoreSymlink "${osConfig.settings.nixConfigDir}/config/mpv/script-opts";
}
