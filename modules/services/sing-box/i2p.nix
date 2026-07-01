{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sing-box-server.i2p;
in
{
  options.services.sing-box-server.i2p.enable = lib.mkEnableOption "i2p";

  config = lib.mkIf cfg.enable {

    services.sing-box-server.settings.outbounds = lib.mkAfter [
      {
        type = "socks";
        tag = "i2p";
        server = "127.0.0.1";
        server_port = 4447;
        version = "5";
      }
    ];

    services.sing-box-server.settings.route.rules = lib.mkAfter [
      {
        action = "route";
        domain_suffix = [ ".i2p" ];
        outbound = "i2p";
      }
    ];

    services.i2pd = {
      enable = true;
      address = "127.0.0.1";
      proto = {
        socksProxy.enable = true;
      };
    };

  };
}
