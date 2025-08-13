{ config, pkgs, lib, ... }: {

  virtualisation.oci-containers.containers.komari-monitor = {
    image = "ghcr.io/komari-monitor/komari:latest";
    volumes = [ "/var/lib/komari-monitor:/app/data" ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.komari.rule=Host(`top.${config.networking.domain}`)"
      "traefik.http.routers.komari.entrypoints=websecure"
    ];
  };


  systemd.services."backup-init@komari-monitor".wantedBy = [ "multi-user.target" ];
  systemd.services."backup-init@komari-monitor".overrideStrategy = "asDropin";

  systemd.services."backup@komari-monitor".startAt = "04:00";
  systemd.services."backup@komari-monitor".overrideStrategy = "asDropin";
}
