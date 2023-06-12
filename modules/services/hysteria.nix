{ pkgs, lib, config, ... }: {

  sops.secrets.password = { };
  sops.secrets.cloudflare-certificate = { };
  sops.secrets.cloudflare-privatekey = { };

  sops.templates.hysteria.content = builtins.toJSON {
    listen = ":6667";
    cert = config.sops.secrets.cloudflare-certificate.path;
    key = config.sops.secrets.cloudflare-privatekey.path;
    obfs = config.sops.placeholder.password;
  };

  systemd.services.hysteria = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.hysteria}/bin/hysteria server -c ${config.sops.templates.hysteria.path}";
    };
  };


}
