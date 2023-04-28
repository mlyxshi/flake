{ config, pkgs, lib, ... }: {

  sops.secrets.restic-env = { };

  virtualisation.oci-containers.containers.changedetection = {
    image = "ghcr.io/dgtlmoon/changedetection.io";
    volumes = [
      "/var/lib/changedetection:/datastore"
    ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.changedetection.rule=Host(`change.${config.networking.domain}`)"
      "traefik.http.routers.changedetection.entrypoints=websecure"
    ];
  };

  systemd.services.podman-changedetection.serviceConfig.StateDirectory = "changedetection";

  systemd.services.changedetection-init = {
    after = [ "network-online.target" ];
    before = [ "podman-changedetection.service" ];
    unitConfig.ConditionPathExists = "!%S/changedetection";
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig.EnvironmentFile = config.sops.secrets.restic-env.path;
    serviceConfig.ExecSearchPath = "${pkgs.restic}/bin";
    serviceConfig.ExecStart = "restic restore latest --path %S/changedetection  --target /";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.changedetection-backup = {
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
}
