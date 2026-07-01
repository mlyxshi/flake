{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sing-box-server.tor;
in
{
  options.services.sing-box-server.tor.enable = lib.mkEnableOption "tor";

  config = lib.mkIf cfg.enable {

    services.sing-box-server.settings.outbounds = lib.mkAfter [
      {
        type = "socks";
        tag = "tor";
        server = "127.0.0.1";
        server_port = 9150;
        version = "5";
      }
    ];

    services.sing-box-server.settings.route.rules = lib.mkAfter [
      {
        action = "route";
        domain_suffix = [ ".onion" ];
        outbound = "tor";
      }
    ];

    users = {
      users.arti = {
        group = "arti";
        isSystemUser = true;
      };
      groups.arti = { };
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
  };
}
