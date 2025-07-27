{ config, pkgs, lib, ... }: {

  virtualisation.oci-containers.containers.pocket-id = {
    image = "ghcr.io/pocket-id/pocket-id:v1";
    volumes = [ "/var/lib/pocket-id:/app/data" ];
    environment = {
      APP_URL = "https://sso.${config.networking.domain}";
      TRUST_PROXY = "true";
      ANALYTICS_DISABLED = "true";
    };
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "traefik.enable=true"
      "traefik.http.routers.pocket-id.rule=Host(`sso.${config.networking.domain}`)"
      "traefik.http.routers.pocket-id.entrypoints=websecure"
    ];
  };

  systemd.services."backup-init@pocket-id".wantedBy = [ "multi-user.target" ];
  systemd.services."backup-init@pocket-id".overrideStrategy = "asDropin";

  systemd.services."backup@pocket-id".startAt = "05:00";
  systemd.services."backup@pocket-id".overrideStrategy = "asDropin";
}
