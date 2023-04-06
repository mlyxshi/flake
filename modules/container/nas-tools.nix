{ pkgs, lib, config, ... }: {

  virtualisation.oci-containers.containers = {
    "nas-tools" = {
      image = "docker.io/jxxghp/nas-tools";
      volumes = [
        "/var/lib/nas-tools:/config"
        "/var/lib/qbittorrent-nox/qBittorrent/downloads:/downloads"
      ];
      environment = {
        "PUID" = "1000";
        "PGID" = "1000";
      };
      extraOptions = [
        "--label"
        "io.containers.autoupdate=registry"
        "--net=host"
      ];
    };


  };

  systemd.services.podman-nas-tools.serviceConfig.StateDirectory = "nas-tools";
  systemd.services.podman-nas-tools.after = [ "podman-nas-tools.service" ];

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.nas-tools = {
          rule = "Host(`nas-tools.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "nas-tools";
          middlewares = "auth";
        };

        services.nas-tools.loadBalancer.servers = [{
          url = "http://127.0.0.1:3000";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-nas-tools = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync nas-tools.${config.networking.domain}";
  };


}
