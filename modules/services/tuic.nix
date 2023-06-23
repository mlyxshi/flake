{ pkgs, lib, config, ... }: {

  sops.secrets.proxy-pwd = { };
  sops.secrets.cloudflare-certificate = { };
  sops.secrets.cloudflare-privatekey = { };

  sops.templates.tuic.content = builtins.toJSON {
    server = "[::]:6666";
    users = {
      "00000000-0000-0000-0000-000000000000" = config.sops.placeholder.proxy-pwd;
    };
    certificate = config.sops.secrets.cloudflare-certificate.path;
    private_key = config.sops.secrets.cloudflare-privatekey.path;
  };

  systemd.services.tuic = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.tuic}/bin/tuic-server -c ${config.sops.templates.tuic.path}";
    };
  };
}