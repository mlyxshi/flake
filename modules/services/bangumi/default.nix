# https://reorx.com/blog/track-and-download-shows-automatically-with-sonarr/
{ lib, ... }: {
  imports = [
    ./qbittorrent.nix

    ../../container/podman.nix
    ../../container/sonarr.nix
    ../../container/jackett.nix
  ];

  networking.nftables.enable = lib.mkForce false;
}
