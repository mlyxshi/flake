{ pkgs, lib, config, ... }: {

  virtualisation.oci-containers.containers = {
    "auto-bangumi" = {
      image = "docker.io/estrellaxd/auto_bangumi";
      volumes = [
        "/var/lib/auto-bangumi:/config"
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

  systemd.services.podman-auto-bangumi.serviceConfig.StateDirectory = "auto-bangumi";
  systemd.services.podman-auto-bangumi.after = [ "qbittorrent-nox.service" ];

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.auto-bangumi = {
          rule = "Host(`auto-bangumi.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "auto-bangumi";
        };

        services.auto-bangumi.loadBalancer.servers = [{
          url = "http://127.0.0.1:3000";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-auto-bangumi = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync auto-bangumi.${config.networking.domain}";
  };


}
