{ pkgs, lib, config, ... }: {
  sops.secrets.restic-env = { };
  
  services.changedetection-io.enable = true;

  systemd.services.changedetection-io-init = {
    after = [ "network-online.target" ];
    before = [ "changedetection-io.service" ];
    unitConfig.ConditionPathExists = "!%S/changedetection-io";
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig.EnvironmentFile = config.sops.secrets.restic-env.path;
    serviceConfig.ExecSearchPath = "${pkgs.restic}/bin";
    serviceConfig.ExecStart = "restic restore latest --path %S/changedetection-io  --target /";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.changedetection-io-backup = {
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.sops.secrets.restic-env.path;
      ExecSearchPath = "${pkgs.restic}/bin";
      ExecStart = [
        "restic backup %S/changedetection-io"
        "restic forget --prune --keep-last 2"
        "restic check"
      ];
    };
    startAt = "08:00";
  };

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.changedetection-io = {
          rule = "Host(`changeio.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "changedetection-io";
        };

        services.changedetection-io.loadBalancer.servers = [{
          url = "http://127.0.0.1:${toString config.services.changedetection-io.port}";
        }];
      };
    };
  };
}

