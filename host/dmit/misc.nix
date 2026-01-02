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

  services.qemuGuest.enable = true; # https://t.me/DMIT_INC_CN/768
  services.openssh.ports = [ 23333 ];

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ct state {established, related} accept
        tcp dport { 23333, 8888, 9999 } accept
        udp dport { 9999 } accept
      }
    }
  '';

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";
}
