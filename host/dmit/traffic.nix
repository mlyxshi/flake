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

  systemd.services.${snell} = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${lib.getExe pkgs.snell} -c /secret/${snell}";
    unitConfig.AssertPathExists = "/secret/${snell}"; # fail if secret is missing
    wantedBy = [ "multi-user.target" ];
  };

  networking.nftables.tables.TRAFFIC = {
    family = "inet";
    content = ''
      quota s0 { over 1 gbytes }

      chain input {
        type filter hook input priority filter; policy accept;
        tcp dport 8888 quota name "s0" drop
      }

      chain output {
        type filter hook output priority filter; policy accept;
        tcp sport 8888 quota name "s0" drop
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

  # # Every minute: if traffic is over the limit, stop snell-share.
  # # Skip entirely once snell-share is already stopped.
  # systemd.services.traffic-guard = {
  #   path = [
  #     pkgs.nftables
  #     traffic-tool
  #   ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = pkgs.writeShellScript "traffic-guard" ''
  #       systemctl is-active --quiet ${snell}.service || exit 0
  #       [ "$(traffic ${port} -b)" -gt ${toString limitBytes} ] && systemctl stop ${snell}.service
  #       exit 0
  #     '';
  #   };
  # };
  # systemd.timers.traffic-guard = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "*:0/1";
  #     OnBootSec = "1min";
  #   };
  # };

  # # Monthly (24th, 00:00 UTC): reset counters and bring snell-share back up.
  # systemd.services.traffic-reset = {
  #   path = [
  #     pkgs.nftables
  #   ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = pkgs.writeShellScript "traffic-reset" ''
  #       nft reset counters table inet TRAFFIC
  #       systemctl restart ${snell}.service
  #     '';
  #   };
  # };
  # systemd.timers.traffic-reset = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig.OnCalendar = "*-*-24 00:00:00 UTC";
  # };
}
