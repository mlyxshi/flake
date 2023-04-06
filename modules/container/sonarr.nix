{ pkgs, lib, config, ... }: {

  virtualisation.oci-containers.containers = {
    "sonarr" = {
      image = "ghcr.io/linuxserver/sonarr:develop";
      volumes = [
        "/var/lib/sonarr/data:/data"
        "/var/lib/sonarr/config:/config"
        "/var/lib/sonarr/downloads:/downloads"
      ];
      environment = {
        "PUID" = "1000";
        "PGID" = "1000";
      };
      extraOptions = lib.concatMap (x: [ "--label" x ]) [
        "io.containers.autoupdate=registry"
        "traefik.enable=true"
        "traefik.http.routers.sonarr.rule=Host(`sonarr.${config.networking.domain}`)"
        "traefik.http.routers.sonarr.entrypoints=websecure"
        "traefik.http.routers.sonarr.middlewares=auth@file"
      ];
    };

  };

  systemd.services.podman-sonarr.serviceConfig.StateDirectory = "sonarr";

  system.activationScripts.cloudflare-dns-sync-sonarr = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync sonarr.${config.networking.domain}";
  };


}
