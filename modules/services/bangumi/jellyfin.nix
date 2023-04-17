{ pkgs, lib, config, ... }: {

  services.jellyfin = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
  };

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.jellyfin = {
          rule = "Host(`jellyfin.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "jellyfin";
        };

        services.jellyfin.loadBalancer.servers = [{
          url = "http://127.0.0.1:8096";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-jellyfin = {
    deps = [ "setupSecrets" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync jellyfin.${config.networking.domain}";
  };
}
