{ config, pkgs, lib, ... }:
let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    python-telegram-bot
  ]);
in
{

  services.caddy.enable = true;
  services.caddy.virtualHosts.":7777".extraConfig = ''
    rewrite * /server/v1/stats
    reverse_proxy localhost:6666
  '';

  systemd.services.ssm = {
    after = [ "sing-box.service" ];
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
    after = [ "sing-box.service" ];
    serviceConfig = {
      ExecStart = "${pythonEnv}/bin/python ${./ssm-tg.py}";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
