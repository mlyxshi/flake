{ self, pkgs, lib, config, ... }: {
  imports = [

  ];

  systemd.services.media-init = {
    script='''';
    serviceConfig.StateDirectory = "media";
    wantedBy = [ "multi-user.target" ];
  };
}
