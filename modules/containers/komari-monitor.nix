{ config, pkgs, lib, ... }: {

  virtualisation.oci-containers.containers.komari-monitor = {
    image = "ghcr.io/komari-monitor/komari:main";
    volumes = [ "/var/lib/komari:/app/data" ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.komari.rule=Host(`top.${config.networking.domain}`)"
      "traefik.http.routers.komari.entrypoints=websecure"
    ];
  };
}
