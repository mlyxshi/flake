{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{

  imports = [
    self.nixosModules.services.cloudflare-warp
    self.nixosModules.services.snell
  ];

  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "154.12.190.105/24";
      Gateway = "154.12.190.105";
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
        tcp dport { 2222, 8888 } accept
        udp dport { 8888 } accept
      }
    }
  '';

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";

}
