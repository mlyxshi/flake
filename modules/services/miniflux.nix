# su postgres 
# psql
# DROP DATABASE ${DB_NAME};
# CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};

# su ${DB_USER}
# pg_dump ${DB_NAME} > backup
# psql ${DB_NAME} < backup
{ config, pkgs, lib, ... }: {

  sops.secrets.user = { };
  sops.secrets.password = { };
  sops.secrets.postgresql = { };
  sops.templates.miniflux-admin-credentials.content = ''
    ADMIN_USERNAME=${config.sops.placeholder.user}
    ADMIN_PASSWORD=${config.sops.placeholder.password}
    DATABASE_URL=${config.sops.placeholder.postgresql}/miniflux
  '';

  sops.templates.miniflux-silent-admin-credentials.content = ''
    ADMIN_USERNAME=${config.sops.placeholder.user}
    ADMIN_PASSWORD=${config.sops.placeholder.password}
    DATABASE_URL=${config.sops.placeholder.postgresql}/miniflux-silent
  '';


  users = {
    users.miniflux = {
      group = "miniflux";
      isNormalUser = true;
    };
    groups.miniflux = { };
  };

  systemd.services.miniflux = {
    after = [ "network-online.target" ];
    environment = {
      PORT = "9080";
      CREATE_ADMIN = "1";
      RUN_MIGRATIONS = "1";
      POLLING_FREQUENCY = "10";
      POLLING_PARSING_ERROR_LIMIT = "0";
      METRICS_COLLECTOR = "1";
      METRICS_ALLOWED_NETWORKS = "0.0.0.0/0";
    };
    serviceConfig = {
      EnvironmentFile = [ config.sops.templates.miniflux-admin-credentials.path ];
      User = "miniflux";
      ExecStart = "${pkgs.miniflux}/bin/miniflux";
    };
    wantedBy = [ "multi-user.target" ];
  };


  # rss to muted tg bot <-- only for tracking Nixpkgs PR
  systemd.services.miniflux-silent = {
    after = [ "network-online.target" ];
    environment = {
      PORT = "9090";
      CREATE_ADMIN = "1";
      RUN_MIGRATIONS = "1";
      POLLING_FREQUENCY = "10";
      POLLING_PARSING_ERROR_LIMIT = "0";
    };
    serviceConfig = {
      EnvironmentFile = [ config.sops.templates.miniflux-silent-admin-credentials.path ];
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
