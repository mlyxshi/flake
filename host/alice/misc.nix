{ config, pkgs, lib, self, ... }: {

  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = [
        "91.103.121.190/27"
        "2a14:67c0:306:7d::a/64"
      ];
      Gateway = "91.103.121.161";
    };

    routes = [
      {
        Gateway = "2a14:67c0:306::1";
        GatewayOnLink = true; #Special config since gateway isn't in subnet
      }
    ];
  };

  # Prefer IPv4 for DNS resolution
  networking.getaddrinfo.precedence."::ffff:0:0/96" = 100;

  systemd.services.komari-agent.environment = {
    AGENT_MONTH_ROTATE = "1";
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

  environment.systemPackages = with pkgs; [
    hath-rust
  ];

  systemd.services.hath = {
    serviceConfig.ExecStart = "${pkgs.hath-rust}/bin/hath-rust";
    serviceConfig.StateDirectory = "hath";
    serviceConfig.WorkingDirectory = "%S/hath";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "hath-init.service" ];
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.hath-init = {
    unitConfig.ConditionPathExists = "!/var/lib/hath/data/client_login";
    script = ''
      mkdir -p /var/lib/hath/data/
      cat /secret/hath > /var/lib/hath/data/client_login 
    '';
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
  };

}
