{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs;
    [
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
      nix-inspect
      nixpkgs-fmt
      joshuto
      helix
      nil
      fd
      ripgrep
      starship
      zoxide
      atuin
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
      gh
      jq
      lazygit
      restic
      home-manager
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      below
      fastfetch
      gptfdisk
    ];
}
