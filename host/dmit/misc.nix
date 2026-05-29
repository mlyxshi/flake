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

  networking.nftables.enable = true;
  networking.nftables.tables.FIREWALL = {
    family = "inet";
    content = ''
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ct state {established, related} accept
        tcp dport { 23333, 8888, 8889, 5201, 8010, 9999 } accept
        udp dport { 5201, 8888, 9999 } accept
      }
    '';
  };

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";
}
