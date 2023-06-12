{ pkgs, lib, config, ... }: {

  sops.secrets.hysteria-obfs = { };
  sops.secrets.hysteria-port = { };
  sops.secrets.cloudflare-certificate = { };
  sops.secrets.cloudflare-privatekey = { };

  sops.templates.hysteria.content = builtins.toJSON {
    listen = ":${config.sops.placeholder.hysteria-port}";
    cert = config.sops.secrets.cloudflare-certificate.path;
    key = config.sops.secrets.cloudflare-privatekey.path;
    obfs = config.sops.placeholder.hysteria-obfs;
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
