{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
{
  services.getty.autologinUser = "root";

  systemd.network.networks.ethernet-static = {
    matchConfig.Name = "en*";
    networkConfig.Address = "154.12.190.105/32";
    routes = [
      {
        Gateway = "193.41.250.250";
        GatewayOnLink = true; # Special config since gateway isn't in subnet
      }
    ];
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ct state {established, related} accept
        tcp dport { 22, 8888 } accept
        udp dport { 8888 } accept
      }
    }
  '';

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";
}
