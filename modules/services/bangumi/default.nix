{ lib, ... }: {
  imports = [
    ./qbittorrent.nix
    ./jellyfin.nix
    ../../container/podman.nix
    ../../container/auto-bangumi.nix
  ];

  networking.nftables.enable = lib.mkForce false;
}
