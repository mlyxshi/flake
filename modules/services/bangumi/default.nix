{ lib, ... }: {
  imports = [
    ./qbittorrent.nix
    ../../container/podman.nix
    ../../container/auto-bangumi.nix
  ];

  networking.nftables.enable = lib.mkForce false;
}