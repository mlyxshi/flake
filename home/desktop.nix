{ pkgs, lib, config, ... }: {

  imports = [
    ./.
    ./firefox
    ./xremap.nix
    ./kde.nix
  ];

}
