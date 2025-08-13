{ config, pkgs, lib, self, ... }: {
  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "103.117.103.126/24";
      Gateway = "103.117.103.1";
    };
  };

  # Prefer IPv4 for DNS resolution
  networking.getaddrinfo.precedence."::ffff:0:0/96" = 100;

  services.openssh.ports = [ 2222 ];

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ct state {established, related} accept
        tcp dport { 2222, 5201, 9997, 9998, 9999 } accept
        udp dport { 5201, 9997, 9998, 9999 } accept
      }
    }
  '';

  services.komari-agent.enable = true;
  services.komari-agent.token = "GX0qa10SyKdenw2o";
  services.komari-agent.include-mountpoint = "/";
  services.komari-agent.include-nics = "eth0";
  services.komari-agent.month-rotate = 24;

  services.vnstat.enable = true;
  # Traffic Reset Date
  environment.etc."vnstat.conf".text = ''
    MonthRotate 24
    UnitMode 1
    Interface "eth0"
  '';
}
