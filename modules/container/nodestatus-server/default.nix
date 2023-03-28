{ pkgs, lib, config, ... }: {

  age.secrets.nodestatus-env.file = ../../../secrets/nodestatus-env.age;

  virtualisation.oci-containers.containers = {
    "nodestatus-server" = {
      image = "docker.io/cokemine/nodestatus";
      volumes = [
        "/var/lib/nodestatus-server:/usr/local/NodeStatus/server"
      ];
      environmentFiles = [
        config.age.secrets.nodestatus-env.path
        config.age.secrets.nodestatus-database.path
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

  };

  systemd.services.podman-nodestatus-server.serviceConfig.StateDirectory = "nodestatus-server";

  system.activationScripts.cloudflare-dns-sync-nodestatus-server = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync top.${config.networking.domain}";
  };


}
