{ config, pkgs, lib, self, ... }:
let
  package = self.packages.${config.nixpkgs.hostPlatform.system}.komari-agent;
in
{
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
        tcp dport { 2222, 5201, 8000, 8888, 8889, 9999 } accept
        udp dport { 5201, 8888, 8889, 9999, 10000 } accept
      }
    }
  '';

  systemd.services."komari-agent" = {
    after = [ "network.target" ];
    path = [ pkgs.vnstat ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${package}/bin/komari-agent -e https://top.mlyxshi.com -t dPC3l2GatkHUQBZP  --disable-web-ssh --disable-auto-update  --month-rotate 24 --include-nics eth0 --include-mountpoint /";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
