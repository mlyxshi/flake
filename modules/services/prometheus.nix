{ config, pkgs, lib, nixpkgs, ... }:
let
  utils = import ../../utils.nix nixpkgs;
  inherit (utils) oracle-serverlist;
in
{
  # https://www.youtube.com/playlist?list=PLLYW3zEOaqlKhRCWqFE7iLRSh3XEFP5gj

  services.prometheus = {
    enable = true;
    webExternalUrl = "https://metric.${config.networking.domain}";
    listenAddress = "127.0.0.1";
    port = 9090;
    retentionTime = "7d";
    globalConfig = {
      scrape_interval = "1m";
      evaluation_interval = "1m";
    };
    scrapeConfigs = [
      {
        job_name = "Node";
        scheme = "http";
        static_configs = [{
          targets = map (x: "${x}.${config.networking.domain}") oracle-serverlist;
        }];
      }

      {
        job_name = "Miniflux";
        scheme = "https";
        static_configs = [{
          targets = [
            "miniflux.${config.networking.domain}"
          ];
        }];
      }
    ];
    rules = [
      (builtins.toJSON {
        groups = [{
          name = "metrics";
          rules = [
            {
              alert = "NodeDown";
              # only apply to Node, exclude Miniflux
              expr = ''up{job="Node"} == 0'';
              for = "3m";
              annotations = {
                summary = "node {{ $labels.instance }} down";
              };
            }
            {
              alert = "UnitFailed";
              expr = ''systemd_units_active_code{job="Node"} == 3'';
              for = "2m";
              annotations = {
                summary = "unit {{ $labels.name }} on {{ $labels.host }} failed";
              };
            }
            {
              alert = "Miniflux Broken Feed";
              expr = ''miniflux_broken_feeds{job="Miniflux"} > 0'';
              for = "600m";
              annotations = {
                summary = "Miniflux Broken Feed";
              };
            }
            {
              alert = "Storage Full";
              expr = ''disk_used_percent{job="Node",path="/var"} > 90'';
              for = "2m";
              annotations = {
                summary = "Storage Full {{ $labels.host }}";
              };
            }
          ];
        }];
      })
    ];

    alertmanagers = [{
      static_configs = [{
        targets = [ "127.0.0.1:9093" ];
      }];
    }];

    alertmanager = {
      enable = true;
      webExternalUrl = "https://alert.${config.networking.domain}";
      listenAddress = "127.0.0.1";
      port = 9093;
      extraFlags = [ ''--cluster.listen-address=""'' ]; # Disable Alertmanager's default high availability feature
      configuration = {
        receivers = [{
          name = "telegram";
          telegram_configs = [{
            bot_token = "$TOKEN";
            chat_id = 337000294;
          }];
        }];
        route = {
          receiver = "telegram";
        };
      };
    };
  };


  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers = {
          prometheus = {
            rule = "Host(`metric.${config.networking.domain}`)";
            entryPoints = [ "websecure" ];
            service = "prometheus";
          };

          alertmanager = {
            rule = "Host(`alert.${config.networking.domain}`)";
            entryPoints = [ "websecure" ];
            service = "alertmanager";
          };

        };

        services = {
          prometheus.loadBalancer.servers = [{
            url = "http://127.0.0.1:9090";
          }];
          alertmanager.loadBalancer.servers = [{
            url = "http://127.0.0.1:9093";
          }];
        };
      };
    };
  };

}
