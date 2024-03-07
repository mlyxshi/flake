{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{

  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.services.backup
  ];

  backup.miniflux-postgres = true;
  backup.miniflux-silent-postgres = true;

  virtualisation.oci-containers.containers.miniflux = {
    image = "ghcr.io/miniflux/miniflux";
    dependsOn = [ "miniflux-postgres" ];
    environment = {
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
    extraOptions =
      lib.concatMap
        (x: [
          "--label"
          x
        ])
        [
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
    image = "ghcr.io/diygod/rsshub:chromium-bundled";
    environment = {
      "PORT" = "80";
    };
    extraOptions = lib.concatMap (x: [
      "--label"
      x
    ]) [ "io.containers.autoupdate=registry" ];
  };

  #################################
  # silent miniflux instance for unimportant feeds

  virtualisation.oci-containers.containers.miniflux-silent = {
    image = "ghcr.io/miniflux/miniflux";
    dependsOn = [ "miniflux-silent-postgres" ];
    environment = {
      # CREATE_ADMIN = "1";
      RUN_MIGRATIONS = "1";
      SCHEDULER_ROUND_ROBIN_MIN_INTERVAL = "10";
      POLLING_FREQUENCY = "10";
      POLLING_PARSING_ERROR_LIMIT = "0";
      METRICS_COLLECTOR = "1";
      METRICS_ALLOWED_NETWORKS = "0.0.0.0/0";
      DATABASE_URL = "postgres://postgres:postgres@miniflux-silent-postgres/miniflux?sslmode=disable";
      BASE_URL = "https://miniflux-silent.${config.networking.domain}";
    };
    extraOptions =
      lib.concatMap
        (x: [
          "--label"
          x
        ])
        [
          "io.containers.autoupdate=registry"
          "traefik.enable=true"
          "traefik.http.routers.miniflux-silent.rule=Host(`miniflux-silent.${config.networking.domain}`)"
          "traefik.http.routers.miniflux-silent.entrypoints=websecure"
        ];
  };

  virtualisation.oci-containers.containers.miniflux-silent-postgres = {
    image = "docker.io/library/postgres:15";
    environment = {
      POSTGRES_USER = "postgres";
      POSTGRES_PASSWORD = "postgres";
      POSTGRES_DB = "miniflux";
    };
    volumes = [ "/var/lib/miniflux-silent-postgres:/var/lib/postgresql/data" ];
  };
}
