{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
let
  python = pkgs.python3.withPackages (ps: [ ps.python-telegram-bot ]);
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
      counter tcp8888_in  { }
      counter tcp8888_out { }
      counter udp8888_in  { }
      counter udp8888_out { }

      chain COUNT_IN {
        type filter hook input priority -10; policy accept;
        meta nfproto ipv4 tcp dport 8888 counter name "tcp8888_in"
        meta nfproto ipv4 udp dport 8888 counter name "udp8888_in"
      }

      chain COUNT_OUT {
        type filter hook output priority -10; policy accept;
        meta nfproto ipv4 tcp sport 8888 counter name "tcp8888_out"
        meta nfproto ipv4 udp sport 8888 counter name "udp8888_out"
      }
    '';
  };

  systemd.services.traffic-bot = {
    after = [
      "network.target"
      "nftables.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.nftables ];
    serviceConfig = {
      ExecStart = "${python}/bin/python3 ${./traffic.py}";
    };
  };
}
