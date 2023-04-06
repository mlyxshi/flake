{ lib, ... }: {
  imports = [
    ./transmission.nix

    ../../container/podman.nix
    ../../container/sonarr.nix
  ];

  networking.nftables.enable = lib.mkForce false;
}
