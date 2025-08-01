{ self, config, pkgs, lib, ... }: {

  environment.systemPackages = with pkgs;[
    cloudflare-warp
  ];


  systemd.services.cloudflare-warp-daemon = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
    serviceConfig.StateDirectory = "cloudflare-warp";
    wantedBy = [ "multi-user.target" ];
  };

}
