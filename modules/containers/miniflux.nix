{ config, pkgs, lib, self, ... }: {
  networking.nftables.enable = lib.mkForce false;

  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.services.backup
  ];

  backup.miniflux-postgres = true;
  backup.miniflux-silent-postgres = true;

  sops.secrets.user = { };
  sops.secrets.password = { };
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
      BASE_URL = "https://test.${config.networking.domain}";
    };
    environmentFiles = [
      config.sops.templates.miniflux-admin-credentials.path
    ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.miniflux.rule=Host(`test.${config.networking.domain}`)"
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
    volumes = [
      "/var/lib/miniflux-postgres:/var/lib/postgresql/data"
    ];
  };


  #################################
  # silent miniflux instance for unimportant feeds

  virtualisation.oci-containers.containers.miniflux-silent = {
    image = "ghcr.io/miniflux/miniflux";
    dependsOn = [
      "miniflux-silent-postgres"
    ];
    environment = {
      CREATE_ADMIN = "1";
      RUN_MIGRATIONS = "1";
      POLLING_FREQUENCY = "10";
      POLLING_PARSING_ERROR_LIMIT = "0";
      METRICS_COLLECTOR = "1";
      METRICS_ALLOWED_NETWORKS = "0.0.0.0/0";
      DATABASE_URL = "postgres://postgres:postgres@miniflux-silent-postgres/miniflux?sslmode=disable";
      BASE_URL = "https://test-silent.${config.networking.domain}";
    };
    environmentFiles = [
      config.sops.templates.miniflux-admin-credentials.path
    ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.miniflux.rule=Host(`test-silent.${config.networking.domain}`)"
      "traefik.http.routers.miniflux.entrypoints=websecure"
    ];
  };

  virtualisation.oci-containers.containers.miniflux-silent-postgres = {
    image = "docker.io/library/postgres:15";
    environment = {
      POSTGRES_USER = "postgres";
      POSTGRES_PASSWORD = "postgres";
      POSTGRES_DB = "miniflux";
    };
    volumes = [
      "/var/lib/miniflux-silent-postgres:/var/lib/postgresql/data"
    ];
  };
}
