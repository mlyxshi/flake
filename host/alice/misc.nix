{ config, pkgs, lib, self, ... }: {

  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = [
        "91.103.121.190/27"
        "2a14:67c0:306:7d::a/64" # IPv6: routed prefix, no gateway
      ];
      Gateway = [
        "91.103.121.161"
      ];
    };
  };

  # Prefer IPv4 for DNS resolution
  networking.getaddrinfo.precedence."::ffff:0:0/96" = 100;

  systemd.services.komari-agent.environment = {
    AGENT_MONTH_ROTATE = "24";
    AGENT_INCLUDE_MOUNTPOINTS = "/";
  };

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";

    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in-basic";
        listen = "0.0.0.0";
        listen_port = 80;
        network = "tcp";
        method = "2022-blake3-aes-128-gcm";
        password = { _secret = "/secret/ss-password-2022"; };
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
