{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
{
  # services.getty.autologinUser = "root";
  # # For security reasons, disable qemu-guest-agent. Enable it temporarily when change IP in dashboard.
  # services.qemuGuest.enable = true;  
  services.openssh.ports = [ 23333 ];

  boot.blacklistedKernelModules = [ "virtio_balloon" ];

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ct state {established, related} accept
        tcp dport { 23333, 8888, 5201 } accept
        udp dport { 5201 } accept
      }
    }
  '';

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";
}
