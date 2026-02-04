{
  pkgs,
  ...
}:
{

  systemd.services.cloudflare-warp-daemon = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${pkgs.cloudflare-warp.override { headless = true; }}/bin/warp-svc";
    serviceConfig.StateDirectory = "cloudflare-warp";
    wantedBy = [ "multi-user.target" ];
  };

}
