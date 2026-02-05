{
  pkgs,
  lib,
  ...
}:
{
  systemd.services.hath = {
    serviceConfig.ExecStart = "${lib.getExe pkgs.hath-rust}";
    serviceConfig.StateDirectory = "hath";
    serviceConfig.WorkingDirectory = "%S/hath";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
}
