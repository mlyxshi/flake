{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.hysteria
    self.nixosModules.services.transmission
  ];

  services.uptime-kuma.enable = true;

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.uptime = {
          rule = "Host(`up.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "uptime";
        };

        services.uptime.loadBalancer.servers = [{ url = "http://127.0.0.1:3001"; }];
      };
    };
  };
}
