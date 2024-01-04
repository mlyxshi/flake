{ pkgs, lib, config, ... }: {

  imports = [
    ./.
    ./firefox
    ./xremap.nix
  ];

}
