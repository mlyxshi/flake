{ config, pkgs, lib, ... }:
let
  transmissionScript = pkgs.writeText "transmission.ts" (''
    #!${pkgs.deno}/bin/deno run --allow-net --allow-env
  '' + builtins.readFile ./transmission.sh);
in
{
  age.secrets.transmission-env.file = ../../../secrets/transmission-env.age;
  age.secrets.rclone-env.file = ../../../secrets/rclone-env.age;
  age.secrets.bark-ios.file = ../../../secrets/bark-ios.age;

  age.secrets.flexget-variables = {
    file = ../../../secrets/flexget-variables.age;
    owner = "transmission";
    group = "transmission";
  };

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
      cat ${transmissionScript} > transmission.ts
      chmod +x transmission.ts
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
    };
    serviceConfig.EnvironmentFile = [
      config.age.secrets.transmission-env.path
      config.age.secrets.bark-ios.path
      config.age.secrets.rclone-env.path
    ];
    serviceConfig.User = "transmission";
    serviceConfig.ExecStart = "${pkgs.transmission}/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
    wantedBy = [ "multi-user.target" ];
  };

  # Wait PR: https://github.com/Flexget/Flexget/pull/3716
  # systemd.services.flexget = {
  #   after = [ "transmission.service" ];
  #   preStart = ''
  #     cat ${./flexget.yml} > config.yml
  #     cat ${config.age.secrets.flexget-variables.path} > variables.yml
  #   '';
  #   serviceConfig = {
  #     User = "transmission";
  #     ExecStart = "${pkgs.flexget}/bin/flexget daemon start";
  #     WorkingDirectory = "%S/flexget";
  #     StateDirectory = "flexget";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

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
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync transmission.${config.networking.domain} transmission-index.${config.networking.domain}";
  };


  networking.nftables.enable = lib.mkForce false;
}
