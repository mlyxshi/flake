{ pkgs, lib, config, ... }: {

  imports = [
    ./.
    ./fish.nix
  ];

  home = {
    username = "runner";
    homeDirectory = "/home/runner";
  };

}
