{ lib, ... }: {
  imports = [
    ./qbittorrent.nix

    ../../container/nas-tools.nix
  ];

  networking.nftables.enable = lib.mkForce false;
}