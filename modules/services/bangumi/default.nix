{ lib, ... }: {
  imports = [
    ./qbittorrent.nix

    ../../container/podman.nix
    ../../container/sonarr.nix
  ];

  networking.nftables.enable = lib.mkForce false;
}
