{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.prometheus
  ];

  services.changedetection-io.enable = true;
  services.changedetection-io.behindProxy = true;
  services.changedetection-io.playwrightSupport = true;
  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.changeio = {
          rule = "Host(`changeio.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "changeio";
        };

        services.changeio.loadBalancer.servers = [{
          url = "http://127.0.0.1:${toString config.services.changedetection-io.port}";
        }];
      };
    };
  };
}
