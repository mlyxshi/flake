# https://jellyfin-plugin-bangumi.pages.dev/repository.json
{ config, pkgs, lib, ... }: {

 virtualisation.oci-containers.containers = {

    "jellyfin" = {
      image = "ghcr.io/linuxserver/jellyfin";
      volumes = [
        "/download/jellyfin/config:/var/lib/jellyfin"
        "/var/lib/media:/var/lib/media"
      ];

      environment = {
        "PUID" = "0";
        "PGID" = "0";
      };
      
      extraOptions = lib.concatMap (x: [ "--label" x ]) [
        "io.containers.autoupdate=registry"
        "traefik.enable=true"
        "traefik.http.routers.jellyfin.rule=Host(`jellyfin.${config.networking.domain}`)"
        "traefik.http.routers.jellyfin.entrypoints=web"
      ];
    };
  };

}