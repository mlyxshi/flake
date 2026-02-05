{
  pkgs,
  lib,
  ...
}:
{

  systemd.services.cloudflare-warp-daemon = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${lib.getExe' (pkgs.cloudflare-warp.override { headless = true; }) "warp-svc"}";
    serviceConfig.StateDirectory = "cloudflare-warp";
    wantedBy = [ "multi-user.target" ];
  };

}
