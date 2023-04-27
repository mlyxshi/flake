{ self, pkgs, lib, config, ... }: {
  imports = [

  ];

  systemd.services.media-init = {
    serviceConfig.StateDirectory = "media";
    wantedBy = [ "multi-user.target" ];
  };
}
