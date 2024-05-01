{ pkgs, lib, config, ... }: {

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
    gdu
    starship
    atuin
    home-manager
    mpv
    yt-dlp
    (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) # Terminal Font
  ];
}
