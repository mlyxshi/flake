{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs;
    [
      wget
      dig
      file
      iperf
      tree
      libarchive
      nix-output-monitor
      nix-tree
      # nix-update
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
      bottom
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
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      gptfdisk
    ];
}
