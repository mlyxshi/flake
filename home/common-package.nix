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
    nixfmt
    htop
    fd
    ripgrep
    fzf
    gdu
    fastfetch
    starship
    atuin
    mpv
    yt-dlp
    (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) # Terminal Font
  ];
}
