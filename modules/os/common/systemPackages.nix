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
    delta
    xh
    tealdeer
    bandwhich
    bat
    bat-extras.batman
    fzf
    gdu
  ] ++ lib.optionals config.settings.developerMode [
    sops
    gh
    nixpkgs-fmt
    jq
    lazygit
    deno
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    restic
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    below
    neofetch
  ];
}
