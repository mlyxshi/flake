{ config, pkgs, lib, ... }: {
  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "103.117.103.126/24";
      Gateway = "103.117.103.1";
    };
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.eth0.use_tempaddr" = 0;
  };

  services.openssh.ports = [ 2222 ];

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        # Drop all incoming traffic by default
        type filter hook input priority 0; policy drop;

        # Allow loopback traffic
        iifname lo accept

        # Allow ICMP
        # ip protocol icmp accept

        # Accept traffic originated from us
        ct state {established, related} accept

        # Only Allow
        tcp dport { 2222, 8000, 8888, 9999 } accept
      }
    }
  '';

  services.vnstat.enable = true;
  # Traffic Reset Date
  environment.etc."vnstat.conf".text = ''
    MonthRotate 24
    UnitMode 1
    Interface "eth0"
  '';

  systemd.services.traffic-api = {
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.python3}/bin/python ${./traffic.py}";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
