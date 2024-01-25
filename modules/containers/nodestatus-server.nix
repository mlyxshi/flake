{ pkgs, lib, config, self, ... }: {

  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.services.backup
  ];

  backup.nodestatus-server = true;

  sops.secrets.user = { };
  sops.secrets.password = { };
  sops.templates.nodestatus-admin-credentials.content = ''
    WEB_USERNAME=${config.sops.placeholder.user}
    WEB_PASSWORD=${config.sops.placeholder.password}
  '';

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

  # systemd.services.podman-nodestatus-server.serviceConfig.StateDirectory = "nodestatus-server";
}
