{ pkgs, lib, config, ... }: {

  services.jellyfin = {
    enable = true;
    user = "transmission";
    group = "transmission";
  };

  systemd.services.media-init = {
    before = [ "transmission.service" ];
    unitConfig.ConditionPathExists = "!%S/media";
    serviceConfig.User = "transmission";
    serviceConfig.StateDirectory = "media";
    script = ''
      mkdir -p /var/lib/media
    '';
    wantedBy = [ "multi-user.target" ];
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

}
