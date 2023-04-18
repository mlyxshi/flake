{ config, pkgs, lib, ... }:
let
  transmissionScript = pkgs.writeShellScript "transmission.sh" ''
    export PATH=$PATH:${pkgs.rclone}/bin:${pkgs.transmission}/bin
    ${pkgs.deno}/bin/deno run --allow-net --allow-env --allow-read --allow-run ${./main.ts}
  '';
in
{

  sops.secrets.transmission-env = { };
  sops.secrets.rclone-env = { };
  sops.secrets.bark-ios = { };
  sops.secrets.flexget-variables = {
    owner = "transmission";
    group = "transmission";
  };

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
      config.sops.secrets.transmission-env.path
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

  systemd.services.flexget = {
    after = [ "transmission.service" ];
    preStart = ''
      cat ${../../../rss.yml} > config.yml
      cat ${config.sops.secrets.flexget-variables.path} > variables.yml
    '';
    serviceConfig = {
      User = "transmission";
      ExecStart = "${pkgs.flexget}/bin/flexget daemon start";
      WorkingDirectory = "%S/flexget";
      StateDirectory = "flexget";
    };
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

  system.activationScripts.cloudflare-dns-sync-transmission = {
    deps = [ "setupSecrets" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync transmission.${config.networking.domain} transmission-index.${config.networking.domain}";
  };


  networking.nftables.enable = lib.mkForce false;
}
