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
    nix-output-monitor
    nix-tree
    nix-init
    nix-update
    joshuto
    helix
    nil
    fd
    ripgrep
    starship
    zoxide
    eza
    xh
    tealdeer
    bandwhich
    bat
    bat-extras.batman
    fzf
    gdu
    git
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    sops
    gh
    nixpkgs-fmt
    jq
    lazygit
    deno
    restic
    home-manager
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    below
    neofetch
  ];
}
