{ pkgs, lib, config, ... }: {

  sops.secrets.password = { };
  sops.secrets.cloudflare-certificate = { };
  sops.secrets.cloudflare-privatekey = { };

  sops.templates.tuic-config.content = builtins.toJSON {
    server = "[::]:6666";
    users = {
      "00000000-0000-0000-0000-000000000000" = config.sops.placeholder.password;
    };
    certificate = config.sops.secrets.cloudflare-certificate.path;
    private_key = config.sops.secrets.cloudflare-privatekey.path;
  };

  systemd.services.tuic = {
    after = [ "tuic-pre.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "%S/tuic/tuic-server -c ${config.sops.templates.tuic-config.path}";
    };
  };

  systemd.services.tuic-pre = {
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "!%S/tuic/tuic-server";

    script = ''
      ${pkgs.wget}/bin/wget https://github.com/EAimTY/tuic/releases/download/tuic-server-1.0.0/tuic-server-1.0.0-$(uname -m)-unknown-linux-musl
      mv tuic-server-1.0.0-$(uname -m)-unknown-linux-musl tuic-server
      chmod +x tuic-server
    '';

    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "%S/tuic";
      StateDirectory = "tuic";
    };
  };
}
