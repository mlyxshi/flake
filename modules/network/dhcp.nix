{
  config,
  pkgs,
  lib,
  ...
}:
{

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_slow_start_after_idle" = 0; # https://www.kawabangga.com/posts/5217
  };

  # Disable nixpkgs defined dhcp
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  systemd.network.enable = true;
  # systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks.ethernet-default-dhcp = {
    matchConfig = {
      Name = [
        "en*"
        "eth*"
      ];
    };
    networkConfig = {
      DHCP = "yes";
    };
  };
  # Disable nixpkgs defined firewall
  # enable firewall by cloud provider web console
  networking.firewall.enable = false;

  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  #   table inet FIREWALL {
  #     chain INPUT {
  #       # Drop all incoming traffic by default
  #       type filter hook input priority 0; policy drop;

  #       # Allow loopback traffic
  #       iifname lo accept

  #       # Allow ICMP
  #       ip protocol icmp accept

  #       # Accept traffic originated from us
  #       ct state {established, related} accept

  #       # Only Allow SSH and Traefik
  #       tcp dport { 22, 80, 443 } accept

  #     }
  #   }
  # '';

  # Enable multicast DNS
  # services.resolved.extraConfig = ''
  #   MulticastDNS=yes
  # '';
  # systemd.network.networks.<name>.networkConfig.MulticastDNS = true;
}
