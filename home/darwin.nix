{
  imports = [
    ./common.nix
    ./firefox
  ];

  home = {
    username = "dominic";
    homeDirectory = "/Users/dominic";
  };

  home.file.".config/yt-dlp/config".text = ''
    --cookies-from-browser firefox
  '';
}
