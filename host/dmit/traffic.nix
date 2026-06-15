# TODO: Rewrite with nft quota

{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
let
  port = "9999";
  snell = "snell-share";

  limitBytes = 150 * 1024 * 1024 * 1024; # set limit /GiB

  python = pkgs.python3.withPackages (ps: [ ps.python-telegram-bot ]);

  # C tool that reads the inet TRAFFIC counters and prints them.
  # `traffic PORT`     -> human-readable breakdown
  # `traffic PORT -b`  -> raw total bytes
  traffic-tool = pkgs.runCommandCC "traffic" { } ''
    mkdir -p $out/bin
    cc -O2 -Wall -o $out/bin/traffic ${./traffic.c}
  '';
in
{

  systemd.services.snell-share1 = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${lib.getExe pkgs.snell} -c /secret/snell-share1";
    unitConfig.AssertPathExists = "/secret/snell-share1"; # fail if secret is missing
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.snell-share2 = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${lib.getExe pkgs.snell} -c /secret/snell-share2";
    unitConfig.AssertPathExists = "/secret/snell-share2"; # fail if secret is missing
    wantedBy = [ "multi-user.target" ];
  };

  networking.nftables.tables.TRAFFIC = {
    family = "inet";
    content = ''
      quota Shallistera { over 102400 mbytes }
      quota williamwang { over 51200 mbytes }

      chain input {
        type filter hook input priority filter; policy accept;
        tcp dport 9999 quota name "Shallistera" drop
        tcp dport 10000 quota name "williamwang" drop
      }

      chain output {
        type filter hook output priority filter; policy accept;
        tcp dport 9999 quota name "Shallistera" drop
        tcp sport 10000 quota name "williamwang" drop
      }
    '';
  };

  # systemd.services.traffic-bot = {
  #   after = [
  #     "network.target"
  #     "nftables.service"
  #   ];
  #   wantedBy = [ "multi-user.target" ];
  #   path = [
  #     pkgs.nftables
  #     traffic-tool
  #   ];
  #   serviceConfig = {
  #     ExecStart = "${python}/bin/python3 ${./traffic-tg-bot.py} ${port}";
  #   };
  #   unitConfig.AssertPathExists = "/secret/bot"; # fail if secret is missing
  # };


  # # Monthly (24th, 00:00 UTC): nft reset quotas
  # systemd.services.traffic-reset = {
  #   path = [
  #     pkgs.nftables
  #   ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "nft reset quotas";
  #   };
  # };
  # systemd.timers.traffic-reset = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig.OnCalendar = "*-*-24 00:00:00 UTC";
  # };
}
