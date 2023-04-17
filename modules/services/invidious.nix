{ config, pkgs, lib, ... }:
let
  # https://github.com/iv-org/invidious/blob/master/config/config.example.yml 
  INVIDIOUS_CONFIG = ''
    # Peer Authentication(System User == Database User), so password is not needed
    database_url: postgres://invidious:dummy@/invidious?host=/run/postgresql
    
    check_tables: true
    external_port: 443
    domain: youtube.${config.networking.domain}
    https_only: true
    registration_enabled: false

    default_user_preferences:
      autoplay: true
      video_loop: true
      quality: dash
      quality_dash: best
      default_home: Search
      feed_menu: []
  '';
in
{
  users = {
    users.invidious = {
      group = "invidious";
      isSystemUser = true;
    };
    groups.invidious = { };
  };

  systemd.services.invidious = {
    after = [ "network-online.target" "postgresql.service" ];
    environment.INVIDIOUS_CONFIG = INVIDIOUS_CONFIG;
    serviceConfig.ExecStart = "${pkgs.invidious}/bin/invidious";
    serviceConfig.User = "invidious";
    wantedBy = [ "multi-user.target" ];
  };

  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_15;
  services.postgresql.initialScript = pkgs.writeText "invidious-postgresql-initScript" ''
    CREATE USER invidious;
    CREATE DATABASE invidious OWNER invidious;
  '';

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.invidious = {
          rule = "Host(`youtube.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "invidious";
        };

        services.invidious.loadBalancer.servers = [{
          url = "http://127.0.0.1:3000";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-libre = {
    deps = [ "setupSecrets" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync youtube.${config.networking.domain}";
  };

}
