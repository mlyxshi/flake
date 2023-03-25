{ config, pkgs, lib, ... }: {

  age.secrets.miniflux-env.file = ../../../secrets/miniflux-env.age;

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
      #isSystemUser = true;
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
}
