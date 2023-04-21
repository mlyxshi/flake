{ config, pkgs, lib, ... }: {
  sops.templates.flexget-conf = {
    # https://flexget.com/en/Configuration
    content = ''
      templates:
        global:
          accept_all: yes
          transmission:
            host: 127.0.0.1
            port: 9091
            username: ${config.sops.placeholder.user}
            password: ${config.sops.placeholder.password}
            labels: 
              - rss

      schedules:
        - tasks: '*'
          interval:
            minutes: 1

    '' + builtins.readFile ../../../rss.yml;

    owner = "transmission";
    group = "transmission";
  };

  systemd.services.flexget = {
    after = [ "transmission.service" ];
    restartTriggers = [ config.sops.templates.flexget-conf.content ];
    preStart = ''
      cat ${config.sops.templates.flexget-conf.path} > config.yml
    '';
    serviceConfig = {
      User = "transmission";
      ExecStart = "${pkgs.flexget}/bin/flexget daemon start";
      WorkingDirectory = "%S/flexget";
      StateDirectory = "flexget";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.media-init = {
    before = [ "transmission.service" ];
    unitConfig.ConditionPathExists = "!%S/media";
    serviceConfig.User = "transmission";
    serviceConfig.StateDirectory = "media";
    script = ''
      mkdir -p /var/lib/media
    '';
    wantedBy = [ "multi-user.target" ];
  };

}
