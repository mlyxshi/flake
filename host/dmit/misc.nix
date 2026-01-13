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

  # services.sing-box.enable = true;
  # services.sing-box.settings = {
  #   log.level = "info";
  #   inbounds = [
  #     {
  #       type = "anytls";
  #       tag = "anytls-in";
  #       listen = "0.0.0.0";
  #       listen_port = 9999;
  #       users = [
  #         {
  #           password = {
  #             _secret = "/secret/ss-password-2022";
  #           };
  #         }
  #       ];
  #       tls = {
  #         enabled = true;
  #         certificate_path = "/secret/self-sign-certificate";
  #         key_path = "/secret/self-sign-key";
  #       };
  #     }
  #   ];
  # };

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";
}
