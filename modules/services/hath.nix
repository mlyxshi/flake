{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{

  systemd.services.hath = {
    serviceConfig.ExecStart = "${pkgs.hath-rust}/bin/hath-rust";
    serviceConfig.StateDirectory = "hath";
    serviceConfig.WorkingDirectory = "%S/hath";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };

}
