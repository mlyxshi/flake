{ self, pkgs, lib, config, ... }: {
  imports = [

  ];

  systemd.services.media-init = {
    serviceConfig.ExecStart = "true";
    serviceConfig.StateDirectory = "media";
    wantedBy = [ "multi-user.target" ];
  };
}
