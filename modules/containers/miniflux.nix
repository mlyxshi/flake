{ config, pkgs, lib, ... }: {

  systemd.services."backup-init@miniflux-postgres".wantedBy = [ "multi-user.target" ];
  systemd.services."backup-init@miniflux-postgres".overrideStrategy = "asDropin";

  systemd.services."backup@miniflux-postgres".startAt = "09:00";
  systemd.services."backup@miniflux-postgres".overrideStrategy = "asDropin";

  virtualisation.oci-containers.containers.miniflux = {
    image = "ghcr.io/miniflux/miniflux:nightly-distroless";
    dependsOn = [ "miniflux-postgres" ];
    environmentFiles = [ /secret/miniflux-oidc ];
    environment = {
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_REDIRECT_URL = "https://miniflux.${config.networking.domain}/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://sso.${config.networking.domain}";
      OAUTH2_USER_CREATION = "1";
      # DISABLE_LOCAL_AUTH = "1";
      # CREATE_ADMIN = "1";
      RUN_MIGRATIONS = "1";
      SCHEDULER_ROUND_ROBIN_MIN_INTERVAL = "10";
      POLLING_FREQUENCY = "10";
      POLLING_PARSING_ERROR_LIMIT = "0";
      METRICS_COLLECTOR = "1";
      METRICS_ALLOWED_NETWORKS = "0.0.0.0/0";
      DATABASE_URL = "postgres://postgres:postgres@miniflux-postgres/miniflux?sslmode=disable";
      BASE_URL = "https://miniflux.${config.networking.domain}";
    };
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.miniflux.rule=Host(`miniflux.${config.networking.domain}`)"
      "traefik.http.routers.miniflux.entrypoints=websecure"
    ];
  };

  virtualisation.oci-containers.containers.miniflux-postgres = {
    image = "docker.io/library/postgres:15";
    environment = {
      POSTGRES_USER = "postgres";
      POSTGRES_PASSWORD = "postgres";
      POSTGRES_DB = "miniflux";
    };
    volumes = [ "/var/lib/miniflux-postgres:/var/lib/postgresql/data" ];
  };

  virtualisation.oci-containers.containers.rsshub = {
    image = "ghcr.io/diygod/rsshub";
    environmentFiles = [ /secret/rsshub ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.rsshub.rule=Host(`rsshub.${config.networking.domain}`)"
      "traefik.http.routers.rsshub.entrypoints=websecure"
    ];
  };

  virtualisation.oci-containers.containers.apprise = {
    image = "ghcr.io/caronc/apprise";
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.apprise.rule=Host(`apprise.${config.networking.domain}`)"
      "traefik.http.routers.apprise.entrypoints=websecure"
    ];
  };
}
