{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
let
  port = "8888";

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
      ExecStart = "${python}/bin/python3 ${./traffic.py} ${port}";
    };
  };
}
