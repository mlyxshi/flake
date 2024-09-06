# open firewall in web console
# ::/0 and 0.0.0.0/0  port 51413 tcp udp
{ config, pkgs, lib, ... }:
let
  transmissionScript = pkgs.writeShellScript "transmission.sh" ''
    export PATH=$PATH:${pkgs.rclone}/bin:${pkgs.transmission}/bin
    ${pkgs.deno}/bin/deno run --allow-net --allow-env --allow-read --allow-run ${
      ./transmission.ts
    }
  '';
in
{
  users = {
    users.transmission = {
      group = "transmission";
      isSystemUser = true;
    };
    groups.transmission = { };
  };

  systemd.services.transmission-init = {
    unitConfig.ConditionPathExists = "!%S/transmission/settings.json";
    script = ''
      cat ${./settings.json} > settings.json
    '';
    serviceConfig.User = "transmission";
    serviceConfig.Type = "oneshot";
    serviceConfig.StateDirectory = "transmission";
    serviceConfig.WorkingDirectory = "%S/transmission";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.transmission = {
    after = [ "transmission-init.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = {
      TRANSMISSION_HOME = "%S/transmission";
      TRANSMISSION_WEB_HOME = "${pkgs.transmission}/public_html";
      DENO_DIR = "%S/transmission/.deno";
    };
    serviceConfig.EnvironmentFile = [ "/secret/transmission" ];
    serviceConfig.User = "transmission";
    serviceConfig.ExecStart = "${pkgs.transmission}/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
    serviceConfig.WorkingDirectory = "%S/transmission";
    # preStart = ''
    #   cat ${transmissionScript} > transmission.sh
    #   chmod +x transmission.sh
    # '';
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
          rule = "Host(`transmission.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "transmission";
        };

        services.transmission.loadBalancer.servers = [{ url = "http://127.0.0.1:9091"; }];

        routers.transmission-index = {
          rule = "Host(`transmission-index.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "transmission-index";
        };

        services.transmission-index.loadBalancer.servers = [{ url = "http://127.0.0.1:8010"; }];
      };
    };
  };
}
