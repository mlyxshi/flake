{
  pkgs,
  lib,
  ...
}:
{
  # services.tor.enable = true;
  # services.tor.client.enable = true;

  # systemd.services.cloudflare-warp-daemon = {
  #   after = [ "network.target" ];
  #   serviceConfig.ExecStart = "${lib.getExe' (pkgs.cloudflare-warp.override {
  #     headless = true;
  #   }) "warp-svc"}";
  #   serviceConfig.StateDirectory = "cloudflare-warp";
  #   wantedBy = [ "multi-user.target" ];
  # };

  users = {
    users = {
      usque = {
        group = "usque";
        isSystemUser = true;
      };
      arti = {
        group = "arti";
        isSystemUser = true;
      };
    };
    groups = {
      usque = { };
      arti = { };
    };
  };

  systemd.services.arti = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "arti";
      Group = "arti";
      StateDirectory = "arti";
      Environment = "HOME=%S/arti";
      ExecStart = "${lib.getExe pkgs.arti} proxy";
    };
  };

  systemd.services.usque = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "usque";
      Group = "usque";
      WorkingDirectory = "%S/usque";
      StateDirectory = "usque";
      ExecStartPre = pkgs.writeShellScript "usque-register" ''
        [ -f config.json ] || ${lib.getExe pkgs.usque} register --accept-tos
      '';
      ExecStart = "${lib.getExe pkgs.usque} socks -b 127.0.0.1 -p 40000";
    };
  };


  services.sing-box-server.enable = true;
  services.sing-box-server.settings = {
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
        server_port = 9150;
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
