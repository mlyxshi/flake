{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
{

  imports = [
    self.nixosModules.programs.vscode-ssh-remote
  ];

  services.openssh.ports = [ 23333 ];

  boot.blacklistedKernelModules = [ "virtio_balloon" ];

  services.caddy.enable = true;
  services.caddy.virtualHosts.":8010".extraConfig = ''
    root * /var/lib/transmission/files
    file_server browse
  '';


  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ct state {established, related} accept
        tcp dport { 23333, 8888, 8889, 5201, 8010 } accept
        udp dport { 5201 } accept
      }
    }
  '';

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";
}
