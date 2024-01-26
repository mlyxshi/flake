{ self, ... }: {
  imports = [
    ./firefox
  ];

  home.stateVersion = "24.05";

  home = {
    username = "dominic";
    homeDirectory = "/Users/dominic";
  };

  nixpkgs.overlays = [ self.overlays.default ];

  home.file.".config/yt-dlp/config".text = ''
    --cookies-from-browser firefox
  '';
}
