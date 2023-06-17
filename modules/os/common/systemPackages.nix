{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    wget
    dig
    file
    iperf
    tree
    htop
    nali
    libarchive
    neovim-unwrapped
    nix-tree
    nix-init
    nix-update
    joshuto
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
    fzf
    gdu
  ] ++ lib.optionals config.settings.developerMode [
    gh
    nixpkgs-fmt
    jq
    lazygit
    deno
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    restic
    rclone
    ideviceinstaller
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    below
    neofetch
  ];
}
