  
{ config, pkgs, name }: {  
  sops.secrets.restic-env = { };

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
    startAt = "08:00";
  };
}