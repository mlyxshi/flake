{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{

  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = [
        "2a14:67c0:306:360::a/128"
      ];
    };

    routes = [
      {
        Gateway = "2a14:67c0:306::1";
        GatewayOnLink = true; # Special config since gateway isn't in subnet
      }
    ];
  };

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";

    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in-basic";
        listen = "::";
        listen_port = 80;
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
