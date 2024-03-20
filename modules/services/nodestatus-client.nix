{ pkgs, lib, config, ... }:
let
  SERVER = "top.${config.networking.domain}";
  USER = config.networking.hostName;
  PASSWORD = config.networking.hostName;
in {
  systemd.services.nodestatus-client = {
    serviceConfig.ExecStart =
      "${pkgs.nodestatus-client}/bin/client -dsn ws://${USER}:${PASSWORD}@${SERVER}";
    serviceConfig.DynamicUser = true;
    wantedBy = [ "multi-user.target" ];
  };
}
