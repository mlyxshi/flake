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

  systemd.services.snell2 = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${lib.getExe pkgs.snell} -c /secret/snell2";
    wantedBy = [ "multi-user.target" ];
  };

  networking.nftables.tables.TRAFFIC = {
    family = "inet";
    content = ''
      counter tcp_${port}_in  { }
      counter tcp_${port}_out { }
      counter udp_${port}_in  { }
      counter udp_${port}_out { }

      chain COUNT_IN {
        type filter hook input priority -10; policy accept;
        meta nfproto ipv4 tcp dport ${port} counter name "tcp_${port}_in"
        meta nfproto ipv4 udp dport ${port} counter name "udp_${port}_in"
      }

      chain COUNT_OUT {
        type filter hook output priority -10; policy accept;
        meta nfproto ipv4 tcp sport ${port} counter name "tcp_${port}_out"
        meta nfproto ipv4 udp sport ${port} counter name "udp_${port}_out"
      }
    '';
  };

  systemd.services.traffic-bot = {
    after = [
      "network.target"
      "nftables.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.nftables
      traffic-tool
    ];
    serviceConfig = {
      ExecStart = "${python}/bin/python3 ${./traffic-tg-bot.py} ${port}";
    };
  };

  # Every minute: if traffic is over the limit, stop snell2.
  # Skip entirely once snell2 is already stopped.
  systemd.services.traffic-guard = {
    path = [
      pkgs.nftables
      traffic-tool
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "traffic-guard" ''
        systemctl is-active --quiet snell2.service || exit 0
        [ "$(traffic ${port} -b)" -gt ${toString limitBytes} ] && systemctl stop snell2.service
        exit 0
      '';
    };
  };
  systemd.timers.traffic-guard = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/1";
      OnBootSec = "1min";
    };
  };

  # Monthly (24th, 00:00 UTC): reset counters and bring snell2 back up.
  systemd.services.traffic-reset = {
    path = [
      pkgs.nftables
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "traffic-reset" ''
        nft reset counters table inet TRAFFIC
        systemctl restart snell2.service
      '';
    };
  };
  systemd.timers.traffic-reset = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "*-*-24 00:00:00 UTC";
  };
}
