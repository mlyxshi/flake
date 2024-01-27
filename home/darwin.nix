{ self, lib, ... }: {
  imports = [
    ./.
    ./firefox
    ./mpv.nix
  ];

  home = {
    username = "dominic";
    homeDirectory = "/Users/dominic";
  };

  nixpkgs.overlays = [ self.overlays.default ];

  home.file.".config/yt-dlp/config".text = ''
    --cookies-from-browser firefox
  '';
}
