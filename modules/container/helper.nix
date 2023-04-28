{ pkgs, lib, config, ... }:
let
  cfg = config.backup;
in
{

  options = {
    backup.changedetection = lib.mkEnableOption "changedetection";
  };

  config = lib.mkMerge [
    {
      sops.secrets.restic-env = { };
    }

    (lib.mkIf cfg.changedetection {
      systemd.services."changedetection-init" = {
        after = [ "network-online.target" ];
        before = [ "podman-changedetection.service" ];
        unitConfig.ConditionPathExists = "!%S/changedetection";
        environment.RESTIC_CACHE_DIR = "%C/restic";
        serviceConfig.EnvironmentFile = config.sops.secrets.restic-env.path;
        serviceConfig.ExecSearchPath = "${pkgs.restic}/bin";
        serviceConfig.ExecStart = "restic restore latest --path %S/changedetection  --target /";
        wantedBy = [ "multi-user.target" ];
      };

      systemd.services."changedetection-backup" = {
        environment.RESTIC_CACHE_DIR = "%C/restic";
        serviceConfig = {
          Type = "oneshot";
          EnvironmentFile = config.sops.secrets.restic-env.path;
          ExecSearchPath = "${pkgs.restic}/bin";
          ExecStart = [
            "restic backup %S/changedetection"
            "restic forget --prune --keep-last 2"
            "restic check"
          ];
        };
        startAt = "08:00";
      };
    })

  ];



}
