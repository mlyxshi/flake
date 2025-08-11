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
    preStart = utils.genJqSecretsReplacementSnippet config-share "/run/sing-box/config.json";
    serviceConfig = {
      StateDirectory = "sing-box";
      RuntimeDirectory = "sing-box";
      ExecStart = "${lib.getExe sing-box-latest} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.ssm = {
    after = [ "sing-box-share.service" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.python3}/bin/python ${./ssm.py}";
    };
  };

  systemd.timers.ssm = {
    timerConfig = {
      OnCalendar = "*:0/1"; # every minute
      AccuracySec = "1s";
    };
    wantedBy = [ "timers.target" ];
  };

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
      ExecStart = "${lib.getExe sing-box-latest} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
