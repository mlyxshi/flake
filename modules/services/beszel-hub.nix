{ pkgs, lib, config, ... }: {
  systemd.services.beszel-hub = {
    after = [ "network.target" ];
    serviceConfig = {
      StateDirectory = "beszel";
      WorkingDirectory = "%S/beszel";
      ExecStart = "${pkgs.beszel}/bin/beszel-hub serve --http '0.0.0.0:8000'";
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


# Oracle ARM 4C24G 4Gbits
# BWG MEGABOX 2C2G 10Gbits 2T(IN+OUT)