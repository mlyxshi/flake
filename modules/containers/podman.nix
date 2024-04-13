{ config, pkgs, lib, ... }: {

  virtualisation.podman.enable = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  systemd.timers.podman-auto-update.wantedBy = [ "timers.target" ];

  systemd.services."backup-init@" = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    before = [ "podman-%i.service" ];
    unitConfig.ConditionPathExists = "!%S/%i";
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig.EnvironmentFile = "/secret/restic";
    serviceConfig.ExecStart =
      "${pkgs.restic}/bin restore latest --path %S/%i  --target /";
  };

  systemd.services."backup@" = {
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "/secret/restic";
      ExecSearchPath = "${pkgs.restic}/bin";
      ExecStart = [
        "restic backup %S/%i"
        "restic forget --prune --keep-last 2"
        "restic check"
      ];
    };
  };
}
