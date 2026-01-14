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

    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in-basic";
        listen = "::";
        listen_port = 8888;
        network = "tcp";
        method = "2022-blake3-aes-128-gcm";
        password = {
          _secret = "/secret/proxy-pwd";
        };
      }
    ];

    outbounds = [
      {
        type = "socks";
        tag = "TW";
        server = "2a14:67c0:116::1";
        server_port = 10001;
        version = "5";
        username = "alice";
        password = "alicefofo123..OVO";
      }
    ];
  };

}
