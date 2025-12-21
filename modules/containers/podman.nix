{
  config,
  pkgs,
  lib,
  ...
}:
{

  virtualisation.podman.enable = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  # Enable podman auto update
  systemd.timers.podman-auto-update.wantedBy = [ "timers.target" ];
  # Podman update may change container IP, so restart traefik and update info
  systemd.services.podman-auto-update.serviceConfig.ExecStartPost = [
    "systemctl restart traefik.service"
  ];

  systemd.services."backup-init@" = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    before = [ "podman-%i.service" ];
    unitConfig.ConditionPathExists = "!%S/%i";
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "/secret/restic";
      ExecStart = "${pkgs.restic}/bin/restic restore latest --path %S/%i  --target /";
    };
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
