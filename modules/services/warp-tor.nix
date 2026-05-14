{
  pkgs,
  lib,
  ...
}:
{
  services.tor.enable = true;
  services.tor.client.enable = true;

  systemd.services.cloudflare-warp-daemon = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${lib.getExe' (pkgs.cloudflare-warp.override {
      headless = true;
    }) "warp-svc"}";
    serviceConfig.StateDirectory = "cloudflare-warp";
    wantedBy = [ "multi-user.target" ];
  };

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    inbounds = [
      {
        type = "anytls";
        tag = "anytls-in";
        listen = "0.0.0.0";
        listen_port = 8889;
        users = [
          {
            password = {
              _secret = "/secret/proxy-pwd";
            };
          }
        ];
        tls = {
          enabled = true;
          insecure = true;
        };
      }
    ];
    outbounds = [
      {
        type = "socks";
        tag = "warp";
        server = "127.0.0.1";
        server_port = 40000;
        version = "5";
      }
      {
        type = "socks";
        tag = "tor";
        server = "127.0.0.1";
        server_port = 9050;
        version = "5";
      }
    ];
    route = {
      rules = [
        {
          action = "route";
          domain_suffix = [ ".onion" ];
          outbound = "tor";
        }
      ];
      final = "warp";
    };
  };
}
