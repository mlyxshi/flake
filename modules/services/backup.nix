{ pkgs, lib, config, ... }:
let
  cfg = config.backup;
  serviceAttr = {
    nodestatus-server = "04:00";
    jellyfin = "05:00";
    vaultwarden = "06:00";
    changedetection = "08:00";
  };
in
{

  options.backup = lib.mapAttrs (service: time: lib.mkEnableOption service) serviceAttr;

  config = lib.mkMerge ([
    {
      sops.secrets.restic-env = { };
    }
  ] ++ lib.mapAttrsToList
    (service: time: (lib.mkIf cfg.${service} {
      systemd.services."${service}-init" = {
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];
        before = [ "podman-${service}.service" ];
        unitConfig.ConditionPathExists = "!%S/${service}";
        environment.RESTIC_CACHE_DIR = "%C/restic";
        serviceConfig.EnvironmentFile = config.sops.secrets.restic-env.path;
        serviceConfig.ExecSearchPath = "${pkgs.restic}/bin";
        serviceConfig.ExecStart = "restic restore latest --path %S/${service}  --target /";
        wantedBy = [ "multi-user.target" ];
      };

      systemd.services."${service}-backup" = {
        environment.RESTIC_CACHE_DIR = "%C/restic";
        serviceConfig = {
          Type = "oneshot";
          EnvironmentFile = config.sops.secrets.restic-env.path;
          ExecSearchPath = "${pkgs.restic}/bin";
          ExecStart = [
            "restic backup %S/${service}"
            "restic forget --prune --keep-last 2"
            "restic check"
          ];
        };
        startAt = time;
      };
    })
    )
    serviceAttr);


}
