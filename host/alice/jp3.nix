{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ct state {established, related} accept
        tcp dport { 23333, 8888 } accept
      }
    }
  '';

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";

    dns.servers = [
      {
        type = "udp";
        tag = "alice-unlock";
        server = "161.248.63.63";
      }
    ];

    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in-basic";
        listen = "::";
        listen_port = 8888;
        network = "tcp";
        method = "2022-blake3-aes-128-gcm";
        password = {
          _secret = "/secret/ss-password-2022";
        };
      }
    ];

    outbounds = [
      {
        type = "direct";
        domain_resolver = {
          strategy = "prefer_ipv4";
          server = "alice-unlock";
        };
      }
    ];
  };

}
