{ pkgs, lib, config, ... }: {

  sops.secrets.proxy-pwd = { };
  sops.secrets.cloudflare-certificate = { };
  sops.secrets.cloudflare-privatekey = { };

  sops.templates.hysteria.name = "hysteria.yaml";
  sops.templates.hysteria.content = ''
    tls: 
      cert: ${config.sops.secrets.cloudflare-certificate.path}
      key: ${config.sops.secrets.cloudflare-privatekey.path}
    auth: 
      type: password
      password: ${config.sops.placeholder.proxy-pwd}
    resolve_preference: 4
    obfs:
      type: salamander
      salamander:
        password: ${config.sops.placeholder.proxy-pwd} 

  '';

  systemd.services.hysteria = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.hysteria}/bin/hysteria server -c ${config.sops.templates.hysteria.path}";
    };
  };
}
