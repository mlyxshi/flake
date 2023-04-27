{ config, pkgs, lib, ... }:
let
  transmissionScript = pkgs.writeShellScript "transmission.sh" ''
    export PATH=$PATH:${pkgs.rclone}/bin:${pkgs.transmission}/bin
    ${pkgs.deno}/bin/deno run --allow-net --allow-env --allow-read --allow-run ${./transmission.ts}
  '';
in
{

  imports = [
    ../../container/podman.nix
    ../../container/jellyfin.nix
    ./flexget.nix
  ];

  networking.nftables.enable = lib.mkForce false;

  sops.secrets.user = { };
  sops.secrets.password = { };
  sops.templates.transmission-admin-credentials.content = ''
    ADMIN=${config.sops.placeholder.user}
    PASSWORD=${config.sops.placeholder.password}
  '';

  sops.secrets.rclone-env = { };
  sops.secrets.bark-ios = { };

  users = {
    users.transmission = {
      group = "transmission";
      isNormalUser = true;
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
    environment = {
      TRANSMISSION_HOME = "%S/transmission";
      TRANSMISSION_WEB_HOME = "${pkgs.transmission}/public_html";
      DENO_DIR = "%S/transmission/.deno";
    };
    serviceConfig.EnvironmentFile = [
      config.sops.templates.transmission-admin-credentials.path
      config.sops.secrets.bark-ios.path
      config.sops.secrets.rclone-env.path
    ];
    serviceConfig.User = "transmission";
    serviceConfig.ExecStart = "${pkgs.transmission}/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
    serviceConfig.WorkingDirectory = "%S/transmission";
    preStart = ''
      cat ${transmissionScript} > transmission.sh
      chmod +x transmission.sh
    '';
    wantedBy = [ "multi-user.target" ];
  };


  systemd.services.transmission-index = {
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.deno}/bin/deno run --allow-net --allow-read https://deno.land/std/http/file_server.ts  %S/transmission/files";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.transmission = {
          rule = "Host(`transmission.${config.networking.domain}`)";
          entryPoints = [ "websecure" ];
          service = "transmission";
        };

        services.transmission.loadBalancer.servers = [{
          url = "http://127.0.0.1:9091";
        }];

        routers.transmission-index = {
          rule = "Host(`transmission-index.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "transmission-index";
        };

        services.transmission-index.loadBalancer.servers = [{
          url = "http://127.0.0.1:4507";
        }];
      };
    };
  };
}
