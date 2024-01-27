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
}
