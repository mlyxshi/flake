{ pkgs, lib, config, ... }: {

  imports = [
    ./.
  ];

  home = {
    username = "runner";
    homeDirectory = "/home/runner";
  };

  home.packages = with pkgs; [ helix joshuto ];
}
