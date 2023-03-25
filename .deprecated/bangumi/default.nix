{ config, pkgs, lib, ... }: {
  age.secrets.telegram-env.file = ../../../secrets/telegram-env.age;

  systemd.services.bangumi = {
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.deno}/bin/deno run --allow-net --allow-env ${./NCRaw.js}";
      EnvironmentFile = [ config.age.secrets.telegram-env.path ];
      # Restart="always";
      # RestartSec=10;
    };
    wantedBy = [ "multi-user.target" ];
  };

}
