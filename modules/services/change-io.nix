{ pkgs, lib, config, ... }: {
  services.changedetection-io.enable = true;
  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.changedetection-io = {
          rule = "Host(`changeio.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "changedetection-io";
        };

        services.changedetection-io.loadBalancer.servers = [{
          url = "http://127.0.0.1:${config.services.changedetection-io.port}";
        }];
      };
    };
  };
}

