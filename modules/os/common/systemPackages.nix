{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs;
    [
      wget
      dig
      file
      htop
      iperf
      tree
      libarchive
      nix-output-monitor
      nix-tree
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
      gdu
      gitMinimal
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      gh
      jq
      lazygit
      restic
      home-manager
      cachix
      nix-init
      nix-update
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      gptfdisk
    ];
}
