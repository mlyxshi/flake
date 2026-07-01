{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sing-box-server.warp;
in
{
  options.services.sing-box-server.warp.enable = lib.mkEnableOption "warp";

  config = lib.mkIf cfg.enable {

    services.sing-box-server.settings.route.final = lib.mkForce "warp";
    services.sing-box-server.settings.outbounds = lib.mkAfter [
      {
        type = "socks";
        tag = "warp";
        server = "127.0.0.1";
        server_port = 40000;
        version = "5";
      }
    ];

    users = {
      users.usque = {
        group = "usque";
        isSystemUser = true;
      };
      groups.usque = { };
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

  };
}
