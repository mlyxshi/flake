{ lib, ... }: {
  imports = [
    ./qbittorrent.nix

    ../../container/auto-bangumi.nix
  ];

  networking.nftables.enable = lib.mkForce false;
}