{ lib, ... }: {
  imports = [
    ./qbittorrent.nix

    ../../container/podman.nix
    ../../container/sonarr.nix
    ../../container/jackett.nix
  ];

  networking.nftables.enable = lib.mkForce false;
}
