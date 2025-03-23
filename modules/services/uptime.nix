{ config, pkgs, lib, ... }: {
  services.uptime-kuma.enable = true;

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.uptime = {
          rule = "Host(`${config.networking.hostName}-up.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "uptime";
        };

        services.uptime.loadBalancer.servers = [{ url = "http://127.0.0.1:3001"; }];
      };
    };
  };
}
