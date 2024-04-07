{ pkgs, lib, config, ... }: {
  systemd.services.hysteria = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart =
        "${pkgs.hysteria}/bin/hysteria server -c /secret/hysteria/config.yaml";
    };
  };
}
