{ pkgs, lib, config, ... }: {

  virtualisation.oci-containers.containers = {
    "jackett" = {
      image = "ghcr.io/linuxserver/jackett";
      volumes = [
        "/var/lib/jackett:/config"
      ];
      extraOptions = [
        "--label"
        "io.containers.autoupdate=registry"
        "--net=host"
      ];
    };


  };

  systemd.services.podman-jackett.serviceConfig.StateDirectory = "jackett";

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.jackett = {
          rule = "Host(`jackett.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "jackett";
          middlewares = "auth";
        };

        services.jackett.loadBalancer.servers = [{
          url = "http://127.0.0.1:9117";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-jackett = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync jackett.${config.networking.domain}";
  };


}
