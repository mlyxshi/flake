# # https://flexget.com/en/Configuration
{ config, pkgs, lib, ... }: {
  sops.templates.flexget-conf.owner = "transmission";
  sops.templates.flexget-conf.content = ''
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
  '' + builtins.readFile ./rss.yml;

  systemd.services.flexget = {
    after = [ "transmission.service" ];
    unitConfig.X-Restart-Triggers =
      builtins.hashString "md5" config.sops.templates.flexget-conf.content;
    preStart = ''
      cat ${config.sops.templates.flexget-conf.path} > config.yml
    '';
    serviceConfig = {
      User = "transmission";
      ExecStart = "${pkgs.flexget}/bin/flexget execute";
      WorkingDirectory = "%S/flexget";
      StateDirectory = "flexget";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.timers.flexget.timerConfig.OnUnitActiveSec = "10min";
  systemd.timers.flexget.wantedBy = [ "timers.target" ];
}
