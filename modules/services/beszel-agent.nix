{ pkgs, lib, config, ... }: {
  systemd.services.beszel-agent = {
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5";
      ExecStart = "${pkgs.beszel}/bin/beszel-agent";
    };
    environment = {
      LISTEN = "45876";
      KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAcPWEp29epKWvw6igPcTVZH5yJZ5dfJFKBSn04b1k9P";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
