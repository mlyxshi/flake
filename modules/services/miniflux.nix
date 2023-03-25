{ config, pkgs, lib, ... }: {

  age.secrets.miniflux-env.file = ../../secrets/miniflux-env.age;
  age.secrets.miniflux-database.file = ../../secrets/miniflux-database.age;
  age.secrets.miniflux-silent-database.file = ../../secrets/miniflux-silent-database.age;

  # rss to unmuted tg bot <-- Important Updates and News
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
      EnvironmentFile = [
        config.age.secrets.miniflux-env.path
        config.age.secrets.miniflux-database.path
      ];
      DynamicUser = true;
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
      EnvironmentFile = [
        config.age.secrets.miniflux-env.path
        config.age.secrets.miniflux-silent-database.path
      ];
      DynamicUser = true;
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

        ########################################################
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


  system.activationScripts.cloudflare-dns-sync-miniflux = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync miniflux-silent.${config.networking.domain} miniflux.${config.networking.domain}";
  };

}
