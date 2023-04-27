{ pkgs, lib, config, ... }: {

  sops.secrets.user = { };
  sops.secrets.password = { };
  sops.templates.nodestatus-admin-credentials.content = ''
    WEB_USERNAME=${config.sops.placeholder.user}
    WEB_PASSWORD=${config.sops.placeholder.password}
  '';

  sops.secrets.restic-env = { };

  virtualisation.oci-containers.containers.nodestatus-server = {
    image = "docker.io/cokemine/nodestatus";
    volumes = [
      "/var/lib/nodestatus-server:/usr/local/NodeStatus/server"
    ];
    environmentFiles = [
      config.sops.templates.nodestatus-admin-credentials.path
    ];
    environment = {
      "VERBOSE" = "false";
      "PING_INTERVAL" = "30";

      "USE_PUSH" = "false";
      "USE_IPC" = "false";
      "USE_WEB" = "true";

      "WEB_TITLE" = "Server Status";
      "WEB_SUBTITLE" = "Servers' Probes Set up with NodeStatus";
      "WEB_HEADTITLE" = "NodeStatus";
    };
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
      "traefik.enable=true"
      "traefik.http.routers.nodestatus.rule=Host(`top.${config.networking.domain}`)"
      "traefik.http.routers.nodestatus.entrypoints=web"
    ];
  };



  systemd.services.podman-nodestatus-server.serviceConfig.StateDirectory = "nodestatus-server";

  systemd.services.nodestatus-data-init = {
    after = [ "network-online.target" ];
    before = [ "podman-nodestatus-server.service" ];
    unitConfig.ConditionPathExists = "!%S/nodestatus-server";
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig.EnvironmentFile = config.sops.secrets.restic-env.path;
    serviceConfig.ExecSearchPath = "${pkgs.restic}/bin";
    serviceConfig.ExecStart = "restic restore latest --path %S/nodestatus-server  --target /";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.nodestatus-backup = {
    environment.RESTIC_CACHE_DIR = "%C/restic";
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.sops.secrets.restic-env.path;
      ExecSearchPath = "${pkgs.restic}/bin";
      ExecStart = [
        "restic backup %S/nodestatus-server"
        "restic forget --prune --keep-last 2"
        "restic check"
      ];
    };
    startAt = "04:00";
  };

}
