{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{

  systemd.network.networks.ethernet-static = {
    matchConfig.Name = "en*";
    networkConfig = {
      Address = [
        "2401:e4e0:100:c8::a/128"
      ];
    };

    routes = [
      {
        Gateway = "2401:e4e0:100::1";
        GatewayOnLink = true; # Special config since gateway isn't in subnet
      }
    ];
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ct state {established, related} accept
        tcp dport { 22, 8888 } accept
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
          _secret = "/secret/ss-password-2022";
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
