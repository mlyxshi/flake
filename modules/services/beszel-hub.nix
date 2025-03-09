{ pkgs, lib, config, ... }: {
  systemd.services.beszel-hub = {
    after = [ "network.target" ];
    serviceConfig = {
      StateDirectory = "beszel";
      WorkingDirectory = "%S/beszel";
      ExecStart = "${pkgs.beszel}/bin/beszel-hub serve --http '0.0.0.0:8008'";
    };
    environment = {
      USER_CREATION = "true";
      SHARE_ALL_SYSTEMS = "true";
    };
    wantedBy = [ "multi-user.target" ];
  };
}


