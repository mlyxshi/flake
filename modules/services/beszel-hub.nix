{ pkgs, lib, config, ... }: {
  systemd.services.beszel-hub = {
    after = [ "network.target" ];
    serviceConfig = {
      StateDirectory = "beszel";
      WorkingDirectory = "%S/beszel";
      ExecStart = "${pkgs.beszel}/bin/beszel-hub serve --http '0.0.0.0:8000'";
    };
    environment = {
      "APP_URL" = "http://top.mlyxshi.com";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.beszel-hub = {
          rule = "Host(`top.mlyxshi.com`)";
          entryPoints = [ "web" ];
          service = "beszel-hub";
        };
        services.beszel-hub.loadBalancer.servers = [{ url = "http://127.0.0.1:8000"; }];
      };
    };
  };
}


