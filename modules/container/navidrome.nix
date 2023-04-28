{ config, pkgs, lib, ... }: {

  virtualisation.oci-containers.containers.navidrome = {
    image = "ghcr.io/navidrome/navidrome";
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.websecure-rsshub.rule=Host(`music.${config.networking.domain}`)"
      "traefik.http.routers.websecure-rsshub.entrypoints=web"
    ];
  };
}
