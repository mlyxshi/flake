{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
    #self.nixosModules.services.backup
  ];

  # backup.miniflux = true;

  sops.secrets.user = { };
  sops.secrets.password = { };
  sops.secrets.postgresql = { };
  sops.templates.miniflux-admin-credentials.content = ''
    ADMIN_USERNAME=${config.sops.placeholder.user}
    ADMIN_PASSWORD=${config.sops.placeholder.password}
  '';

  virtualisation.oci-containers.containers.miniflux = {
    image = "ghcr.io/miniflux/miniflux";
    dependsOn = [
      "miniflux-postgres"
    ];
    environment = {
      CREATE_ADMIN = "1";
      RUN_MIGRATIONS = "1";
      POLLING_FREQUENCY = "10";
      POLLING_PARSING_ERROR_LIMIT = "0";
      METRICS_COLLECTOR = "1";
      METRICS_ALLOWED_NETWORKS = "0.0.0.0/0";
      DATABASE_URL = "postgres://postgres:postgres@miniflux-postgres/miniflux?sslmode=disable";
    };
    environmentFiles = [
      config.sops.templates.miniflux-admin-credentials.path
    ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.miniflux.rule=Host(`test.${config.networking.domain}`)"
      "traefik.http.routers.miniflux.entrypoints=websecure"
    ] ++ [ "--no-healthcheck" ];
  };

  virtualisation.oci-containers.containers.miniflux-postgres = {
    image = "docker.io/library/postgres:15";
    environment = {
      POSTGRES_USER = "postgres";
      POSTGRES_PASSWORD = "postgres";
      POSTGRES_DB = "miniflux";
    };
    volumes = [
      "/var/lib/miniflux-postgres:/var/lib/postgresql/data"
    ];
  };

  systemd.services.podman-miniflux-postgres.serviceConfig.StateDirectory = "miniflux-postgres";
}
