{ pkgs, lib, config, ... }: {

  sops.secrets.proxy-pwd = { };
  sops.secrets.cloudflare-certificate = { };
  sops.secrets.cloudflare-privatekey = { };

  sops.templates.hysteria.name = "hysteria.yaml";
  sops.templates.hysteria.content = ''
    listen: :8888 
    tls: 
      cert: ${config.sops.secrets.cloudflare-certificate.path}
      key: ${config.sops.secrets.cloudflare-privatekey.path}
    auth: 
      type: password
      password: ${config.sops.placeholder.proxy-pwd}
  '';

  systemd.services.hysteria = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.hysteria}/bin/app server -c ${config.sops.templates.hysteria.path}";
    };
  };
}
