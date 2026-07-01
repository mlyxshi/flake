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
    self.nixosModules.services.sing-box
  ];

  services.sing-box-server.tor.enable = true;
  services.sing-box-server.warp.enable = true;

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
        tcp dport { 23333, 8888, 8889, 5201, 8010, 9999, 10000 } accept
        udp dport { 5201 } accept
      }
    '';
  };

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";
}
