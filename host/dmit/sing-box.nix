{ config, pkgs, lib, utils, ... }:
let
  sing-box-beta = pkgs.sing-box.overrideAttrs (previousAttrs: {
    pname = previousAttrs.pname + "-beta";
    version = "2.12";
    src = pkgs.fetchFromGitHub {
      owner = "SagerNet";
      repo = "sing-box";
      rev = "66a767d083fd37b3cd071466636e645bfc96bc96";
      hash = "sha256-2R89tGf2HzPzcytIg7/HxbEP/aDMZ6MxZOk6Z8C1hZA=";
    };
    vendorHash = "sha256-tyGCkVWfCp7F6NDw/AlJTglzNC/jTMgrL8q9Au6Jqec=";
    tags = [ "with_gvisor" "with_quic" "with_dhcp" "with_wireguard" "with_utls" "with_acme" "with_clash_api" "with_tailscale" ];
  });

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [ python-telegram-bot ]);

  config-share = {
    log.level = "info";
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in";
        listen = "0.0.0.0";
        listen_port = 9999;
        managed = true;
        method = "2022-blake3-aes-128-gcm";
        password = { _secret = "/secret/ss-password-2022"; };
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
  systemd.services.sing-box-share = {
    after = [ "network.target" ];
    preStart = utils.genJqSecretsReplacementSnippet config-share "/run/sing-box/config.json";
    serviceConfig = {
      StateDirectory = "sing-box";
      RuntimeDirectory = "sing-box";
      ExecStart = "${lib.getExe sing-box-beta} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run";
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
      ExecStart = "${lib.getExe sing-box-beta} -D \${STATE_DIRECTORY} -C \${RUNTIME_DIRECTORY} run";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
