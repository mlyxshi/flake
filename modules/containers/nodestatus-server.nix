{ pkgs, lib, config, ... }: {

  virtualisation.oci-containers.containers.nodestatus-server = {
    image = "docker.io/cokemine/nodestatus";
    volumes = [ "/var/lib/nodestatus-server:/usr/local/NodeStatus/server" ];
    environmentFiles = [ "/secret/nodestatus-server" ];
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

  systemd.services."backup-init@nodestatus-server".wantedBy =
    [ "multi-user.target" ];
  systemd.services."backup-init@nodestatus-server".overrideStrategy =
    "asDropin";

  systemd.services."backup@nodestatus-server".startAt = "04:00";
  systemd.services."backup@nodestatus-server".overrideStrategy = "asDropin";
}
