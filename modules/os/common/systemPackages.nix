{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    # basic
    wget
    dig
    file
    tree
    htop
    libarchive
    neovim-unwrapped
    nix-tree
    nix-init
    nix-update
    # rust
    fd
    ripgrep
    starship
    zoxide
    exa
    delta
    xh
    tealdeer
    bandwhich
    bat
    bat-extras.batman
    # go
    lf
    fzf
    pistol
    gdu
  ] ++ lib.optionals config.settings.developerMode [
    gh
    nixpkgs-fmt
    jq
    lazygit
    deno
    cf-terraforming
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    restic
    rclone
    ideviceinstaller
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    parted
    below
    neofetch
  ];
}
