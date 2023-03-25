# su postgres 
# psql
# DROP DATABASE ${DB_NAME};
# CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};

# su ${DB_USER}
# pg_dump ${DB_NAME} > backup
# psql ${DB_NAME} < backup
{ config, pkgs, lib, ... }: {

  age.secrets.miniflux-env.file = ../../secrets/miniflux-env.age;
  age.secrets.restic-env.file = ../../secrets/restic-env.age;

  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_15;
  services.postgresql.initialScript = pkgs.writeText "miniflux-postgresql-initScript" ''
    CREATE USER miniflux;
    CREATE DATABASE miniflux OWNER miniflux;
    CREATE DATABASE "miniflux-silent" OWNER miniflux;
    CREATE EXTENSION hstore;
  '';

  users = {
    users.miniflux = {
      group = "miniflux";
      isNormalUser = true;
    };
    groups.miniflux = { };
  };

  systemd.services.miniflux = {
    after = [ "network-online.target" "postgresql.service" ];
    environment = {
      DATABASE_URL = "user=miniflux dbname=miniflux host=/run/postgresql sslmode=disable";
      PORT = "9080";
      CREATE_ADMIN = "1";
      RUN_MIGRATIONS = "1";
      POLLING_FREQUENCY = "10";
      POLLING_PARSING_ERROR_LIMIT = "0";
      METRICS_COLLECTOR = "1";
      METRICS_ALLOWED_NETWORKS = "0.0.0.0/0";
    };
    serviceConfig = {
      EnvironmentFile = [ config.age.secrets.miniflux-env.path ];
      User = "miniflux";
      ExecStart = "${pkgs.miniflux}/bin/miniflux";
    };
    wantedBy = [ "multi-user.target" ];
  };


  # rss to muted tg bot <-- only for tracking Nixpkgs PR
  systemd.services.miniflux-silent = {
    after = [ "network-online.target" "postgresql.service" ];
    environment = {
      DATABASE_URL = "user=miniflux dbname=miniflux-silent host=/run/postgresql sslmode=disable";
      PORT = "9090";
      CREATE_ADMIN = "1";
      RUN_MIGRATIONS = "1";
      POLLING_FREQUENCY = "10";
      POLLING_PARSING_ERROR_LIMIT = "0";
    };
    serviceConfig = {
      EnvironmentFile = [ config.age.secrets.miniflux-env.path ];
      User = "miniflux";
      ExecStart = "${pkgs.miniflux}/bin/miniflux";
    };
    wantedBy = [ "multi-user.target" ];
  };


  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.miniflux = {
          rule = "Host(`miniflux.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "miniflux";
        };

        services.miniflux.loadBalancer.servers = [{
          url = "http://127.0.0.1:9080";
        }];

        #######################################################
        routers.miniflux-silent = {
          rule = "Host(`miniflux-silent.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "miniflux-silent";
        };

        services.miniflux-silent.loadBalancer.servers = [{
          url = "http://127.0.0.1:9090";
        }];
      };
    };
  };




  systemd.services.psql-miniflux-backup = {
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig = {
      User = "miniflux";
      EnvironmentFile = config.age.secrets.restic-env.path;
    };
    script = '' 
      ${config.services.postgresql.package}/bin/pg_dump miniflux | ${pkgs.restic}/bin/restic backup --stdin --stdin-filename miniflux.sql
      ${config.services.postgresql.package}/bin/pg_dump miniflux-silent | ${pkgs.restic}/bin/restic backup --stdin --stdin-filename miniflux-silent.sql
      ${pkgs.restic}/bin/restic forget --prune --keep-last 2
      ${pkgs.restic}/bin/restic check
    '';
    startAt = "05:00";
  };

  system.activationScripts.cloudflare-dns-sync-miniflux = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync miniflux-silent.${config.networking.domain} miniflux.${config.networking.domain}";
  };
}
