# open firewall in web console
# ::/0 and 0.0.0.0/0  port 51413 tcp udp
{
  config,
  pkgs,
  nixpkgs,
  self,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      transmission = prev.callPackage (self + "/pkgs/transmission.nix") { };
    })
  ];

  users = {
    users.transmission = {
      group = "transmission";
      isSystemUser = true;
    };
    groups.transmission = { };
  };

  systemd.tmpfiles.settings."10-transmission-init" = {
    "/var/lib/transmission".d = {
      user = "transmission";
      group = "transmission";
    };

    "/var/lib/transmission/settings.json".C = {
      user = "qbittorrent";
      group = "qbittorrent";
      argument = (
        pkgs.writeText "settings.json" ''
          {
            "rpc-whitelist-enabled": false,
            "rpc-authentication-required": true,
            "download-dir": "/var/lib/transmission/Downloads"
          }
        ''
      );
    };
  };

  systemd.services.transmission = {
    after = [
      "transmission-init.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    environment = {
      TRANSMISSION_HOME = "%S/transmission";
      TRANSMISSION_WEB_HOME = "${pkgs.transmission}/share/transmission/public_html";
    };
    serviceConfig.EnvironmentFile = [ "/secret/transmission" ];
    serviceConfig.User = "transmission";
    serviceConfig.ExecStart = "${pkgs.transmission}/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
    serviceConfig.WorkingDirectory = "%S/transmission";
    wantedBy = [ "multi-user.target" ];
  };

  services.caddy.enable = true;
  services.caddy.virtualHosts.":8010".extraConfig = ''
    root * /var/lib/transmission/files
    file_server browse
  '';

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.transmission = {
          rule = "Host(`transmission-${config.networking.hostName}.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "transmission";
        };

        services.transmission.loadBalancer.servers = [ { url = "http://127.0.0.1:9091"; } ];

        routers.transmission-index = {
          rule = "Host(`transmission-${config.networking.hostName}-index.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "transmission-index";
        };

        services.transmission-index.loadBalancer.servers = [ { url = "http://127.0.0.1:8010"; } ];
      };
    };
  };
}
