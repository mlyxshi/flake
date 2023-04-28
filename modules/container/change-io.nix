{ config, pkgs, lib, ... }: {

  imports=[
    ./helpers.nix { name = "changedetection"; }
  ];

  virtualisation.oci-containers.containers.changedetection = {
    image = "ghcr.io/dgtlmoon/changedetection.io";
    volumes = [
      "/var/lib/changedetection:/datastore"
    ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.changedetection.rule=Host(`changeio.${config.networking.domain}`)"
      "traefik.http.routers.changedetection.entrypoints=websecure"
    ];
  };

  systemd.services.podman-changedetection.serviceConfig.StateDirectory = "changedetection";


}
