{ config, pkgs, lib, self, ... }: {

  imports = [
    self.nixosModules.services.cloudflare-warp
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
        tcp dport { 2222, 80, 443, 444 } accept
        udp dport { 5201 } accept
      }
    }
  '';

  systemd.services.komari-agent.environment = {
    AGENT_MONTH_ROTATE = "24";
    AGENT_INCLUDE_MOUNTPOINTS = "/";
  };

  services.sing-box.enable = true;
  services.sing-box.settings = import ./sing-box-config.nix;

}
