{ config, pkgs, lib, ... }:
let
  rcloneScript = pkgs.writeShellScript "rclone.sh" (''
    export PATH=$PATH:${pkgs.rclone}/bin:${pkgs.curl}/bin:${pkgs.transmission}/bin
  '' + builtins.readFile ./rclone.sh);
in
{
  age.secrets.transmission-env.file = ../../../secrets/transmission-env.age;
  age.secrets.rclone-env.file = ../../../secrets/rclone-env.age;
  age.secrets.telegram-env.file = ../../../secrets/telegram-env.age;

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

      cat ${rcloneScript} > rclone.sh 
      chmod +x rclone.sh
    '';
    serviceConfig.User = "transmission";
    serviceConfig.Type = "oneshot";
    serviceConfig.StateDirectory = "transmission";
    serviceConfig.WorkingDirectory = "%S/transmission";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.transmission = {
    after = [ "transmission-init.service" ];
    environment = {
      TRANSMISSION_HOME = "%S/transmission";
      TRANSMISSION_WEB_HOME = "${pkgs.transmission}/public_html";
    };
    serviceConfig.EnvironmentFile = [
      config.age.secrets.transmission-env.path
      config.age.secrets.telegram-env.path
      config.age.secrets.rclone-env.path
    ];
    serviceConfig.User = "transmission";
    serviceConfig.ExecStart = "${pkgs.transmission}/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
    wantedBy = [ "multi-user.target" ];
  };


  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.transmission = {
          rule = "Host(`transmission.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "transmission";
        };

        services.transmission.loadBalancer.servers = [{
          url = "http://127.0.0.1:9091";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-transmission = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync transmission.${config.networking.domain}";
  };


  networking.nftables.enable = lib.mkForce false;
}
