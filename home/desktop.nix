{ pkgs, lib, config, self, ... }: {

  imports = [
    ./.
    ./firefox
    ./mpv.nix
    #./xremap.nix 
    ./kde.nix
  ];

  nixpkgs.overlays = [ self.overlays.default ];

  fonts.fontconfig.enable = true;
}
