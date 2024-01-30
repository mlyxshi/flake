{ pkgs, lib, config, self, ... }: {

  imports = [
    ./.
    ./firefox
    ./mpv.nix
    ./xremap.nix
    ./kde.nix
  ];

  nixpkgs.overlays = [ self.overlays.default ];

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
    mpv
    yt-dlp
    (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) # Terminal Font
  ];

  fonts.fontconfig.enable = true;

}
