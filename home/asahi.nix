{ pkgs, lib, config, self, ... }: {

  imports = [
    ./.
    ./firefox
    ./kde.nix
    ./fish.nix
  ];

  home = {
    username = "dominic";
    homeDirectory = "/home/dominic";
  };

  home.packages = with pkgs; [
    eza
    joshuto
    bat
    bat-extras.batman
    lazygit
    helix
    git
    zoxide
    nil
    nixpkgs-fmt
    htop
    fd
    ripgrep
    fzf
    gdu
    neofetch
    starship
    home-manager
    atuin
    (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) # Terminal Font
  ];

  fonts.fontconfig.enable = true;

}
