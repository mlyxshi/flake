# https://jellyfin-plugin-bangumi.pages.dev/repository.json
{ pkgs, lib, config, ... }: {

  sops.secrets.restic-env = { };

  services.jellyfin = {
    enable = true;
    user = "transmission";
    group = "transmission";
  };

  systemd.services.jellyfin-data-init = {
    after = [ "transmission.service" ];
    before = [ "jellyfin.service" ];
    unitConfig.ConditionPathExists = "!%S/jellyfin";
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig.EnvironmentFile = config.sops.secrets.restic-env.path;
    serviceConfig.ExecSearchPath = "${pkgs.restic}/bin";
    serviceConfig.ExecStart = "restic restore latest --path %S/jellyfin  --target /";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.jellyfin-backup = {
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.sops.secrets.restic-env.path;
      ExecSearchPath = "${pkgs.restic}/bin";
      ExecStart = [
        "restic backup %S/jellyfin"
        "restic forget --prune --keep-last 2"
        "restic check"
      ];
    };
    startAt = "07:00";
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
