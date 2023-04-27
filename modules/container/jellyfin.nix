# https://jellyfin-plugin-bangumi.pages.dev/repository.json
{ config, pkgs, lib, ... }: {

  sops.secrets.restic-env = { };

  virtualisation.oci-containers.containers.jellyfin = {
    image = "ghcr.io/linuxserver/jellyfin";
    volumes = [
      "/var/lib/jellyfin:/config"
      "/var/lib/media:/var/lib/media"
    ];

    environment = {
      "PUID" = "0";
      "PGID" = "0";
    };

    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.jellyfin.rule=Host(`jellyfin.${config.networking.domain}`)"
      "traefik.http.routers.jellyfin.entrypoints=web"
    ];
  };

  systemd.services.media-init = {
    before = [ "transmission.service" "podman-jellyfin.service" ];
    unitConfig.ConditionPathExists = "!%S/media";
    serviceConfig.User = "transmission";
    serviceConfig.ExecStart = "echo"; # dummy command to make StateDirectory work
    serviceConfig.StateDirectory = "media";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.jellyfin-data-init = {
    after = [ "network-online.target" ];
    before = [ "podman-jellyfin.service" ];
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
    startAt = "05:00";
  };

}
