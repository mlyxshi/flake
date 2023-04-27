{ self, pkgs, lib, config, ... }: {
  imports = [

  ];

  systemd.services.media-init = {
    script=''echo'';
    serviceConfig.StateDirectory = "media";
    wantedBy = [ "multi-user.target" ];
  };
}
