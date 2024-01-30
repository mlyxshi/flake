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

  programs.firefox.package = null;

  nixpkgs.overlays = [ self.overlays.default ];
}
