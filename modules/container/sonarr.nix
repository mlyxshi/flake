{ pkgs, lib, config, ... }: {

  virtualisation.oci-containers.containers = {
    "sonarr" = {
      image = "ghcr.io/linuxserver/sonarr:develop";
      volumes = [
        "/var/lib/sonarr/config:/config"
        "/var/lib/sonarr/data:/data"
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

  systemd.services.podman-sonarr.after = [ "qbittorrent-nox.service" ];
  systemd.services.podman-sonarr.serviceConfig.StateDirectory = "sonarr";
  systemd.services.podman-sonarr.preStart = ''
    mkdir -p /var/lib/sonarr/{config,data,downloads}
    chown -R 1000:1000 /var/lib/sonarr/{config,data,downloads}  
  '';

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.sonarr = {
          rule = "Host(`sonarr.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "sonarr";
        };

        services.sonarr.loadBalancer.servers = [{
          url = "http://127.0.0.1:8989";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-sonarr = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync sonarr.${config.networking.domain}";
  };


}
