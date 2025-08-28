{ config, pkgs, lib, utils, self, ... }:
let
  sing-box-latest = self.packages.${config.nixpkgs.hostPlatform.system}.sing-box;

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [ python-telegram-bot ]);

  config-share = {
    log.level = "info";
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in";
        listen = "0.0.0.0";
        listen_port = 9999;
        network = "tcp";
        method = "2022-blake3-aes-128-gcm";
        password = { _secret = "/secret/ss-password-2022"; };
        multiplex = { enabled = true; };
        managed = true;
      }
    ];
    services = [
      {
        type = "ssm-api";
        servers = { "/" = "ss-in"; };
        cache_path = "cache.json";
        listen = "0.0.0.0";
        listen_port = 6666;
      }
    ];
  };
  config-my = import ./sing-box-config.nix;
in
{

  imports = [
    self.nixosModules.services.cloudflare-warp
  ];

  systemd.services.sing-box-share = {
    after = [ "network.target" ];
    preStart = utils.genJqSecretsReplacementSnippet config-share "/run/sing-box-share/config.json";
    serviceConfig = {
      StateDirectory = "sing-box-share";
      RuntimeDirectory = "sing-box-share";
      ExecStart = "${lib.getExe pkgs.sing-box} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Every UTC+8 4:00 am restart sing-box-share to backup traffic stats
  systemd.services.sing-box-share-restart = {
    serviceConfig.ExecStart = "${pkgs.systemd}/bin/systemctl restart sing-box-share.service";
  };

  systemd.timers.sing-box-share-restart = {
    timerConfig = {
      OnCalendar = "*-*-* 20:00:00";
      AccuracySec = "1s";
    };
    wantedBy = [ "timers.target" ];
  };

  # Every 1 minute check and delete users who exceed data limit
  systemd.services.ssm = {
    after = [ "sing-box-share.service" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.python3}/bin/python ${./ssm.py}";
    };
  };

  systemd.timers.ssm = {
    timerConfig = {
      OnCalendar = "*:0/1";
      AccuracySec = "1s";
    };
    wantedBy = [ "timers.target" ];
  };

  # Every month reset user stats
  systemd.services.ssm-month = {
    after = [ "sing-box-share.service" ];
    path = [ pkgs.curl ];
    serviceConfig = {
      ExecStart = "/secret/ssm-reset.sh";
    };
  };


  systemd.timers.ssm-month = {
    timerConfig = {
      OnCalendar = "*-*-24 00:00:00";
      AccuracySec = "1s";
    };
    wantedBy = [ "timers.target" ];
  };

  # TG bot
  systemd.services.ssm-tg = {
    after = [ "sing-box-share.service" ];
    serviceConfig = {
      ExecStart = "${pythonEnv}/bin/python ${./ssm-tg.py}";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.sing-box-my = {
    after = [ "network.target" ];
    preStart = utils.genJqSecretsReplacementSnippet config-my "/run/sing-box-my/config.json";
    serviceConfig = {
      StateDirectory = "sing-box-my";
      RuntimeDirectory = "sing-box-my";
      ExecStart = "${lib.getExe pkgs.sing-box} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
