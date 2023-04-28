{ pkgs, lib, config, ... }:
let
  cfg = config.backup;
  servicelist = {
    changedetection = "08:00";
    jellyfin = "05:00";
  };
in
{
  options.backup = lib.genAttrs (builtins.attrNames servicelist) (x: lib.mkEnableOption x);

  config = lib.mkMerge [
    {
      sops.secrets.restic-env = { };
    }
  ] ++ lib.mapAttrsToList
    (name: value:

      (lib.mkIf cfg.name {
        systemd.services."${name}-init" = {
          after = [ "network-online.target" ];
          before = [ "podman-${name}.service" ];
          unitConfig.ConditionPathExists = "!%S/${name}";
          environment.RESTIC_CACHE_DIR = "%C/restic";
          serviceConfig.EnvironmentFile = config.sops.secrets.restic-env.path;
          serviceConfig.ExecSearchPath = "${pkgs.restic}/bin";
          serviceConfig.ExecStart = "restic restore latest --path %S/${name}  --target /";
          wantedBy = [ "multi-user.target" ];
        };

        systemd.services."${name}-backup" = {
          environment.RESTIC_CACHE_DIR = "%C/restic";
          serviceConfig = {
            Type = "oneshot";
            EnvironmentFile = config.sops.secrets.restic-env.path;
            ExecSearchPath = "${pkgs.restic}/bin";
            ExecStart = [
              "restic backup %S/${name}"
              "restic forget --prune --keep-last 2"
              "restic check"
            ];
          };
          startAt = value;
        };
      })
    )
    servicelist;



}
