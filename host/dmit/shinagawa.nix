{ config, pkgs, lib, ... }: {
  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "103.117.103.126/24";
      Gateway = "103.117.103.1";
      IPv6AcceptRA = true;
    };

    # networkConfig = {
    #   Address = [
    #     "103.117.103.126/24"
    #     "2403:18c0:1001:179:787a:20ff:fe99:43a5/64"
    #   ];
    #   Gateway = [ 
    #     "103.117.103.1"
    #     "2403:18c0:1001:179::1"
    #   ];
    # };
  };

  # Prefer IPv4 for DNS resolution
  # networking.getaddrinfo.precedence."::ffff:0:0/96" = 100;
  # Disble IPv6 temporary addresses
  # boot.kernel.sysctl."net.ipv6.conf.eth0.use_tempaddr" = 0;


  services.openssh.ports = [ 2222 ];

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ct state {established, related} accept
        tcp dport { 2222, 5201, 8000, 8888, 9999, 45876 } accept
        udp dport { 8888 } accept
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
