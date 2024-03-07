{
  pkgs,
  lib,
  config,
  ...
}:
{
  systemd.services.hysteria = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.hysteria}/bin/hysteria server -c /etc/secret/hysteria/config.yaml";
    };
  };
}
