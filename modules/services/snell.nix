{
  pkgs,
  lib,
  ...
}:
{
  systemd.services.snell = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${lib.getExe pkgs.snell} -c /secret/snell";
    wantedBy = [ "multi-user.target" ];
  };
}
