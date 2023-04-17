{ pkgs, lib, config, ... }: {

  sops.secrets.shadowsocks-pwd = { };

  sops.templates.shadowsocks-config.content = builtins.toJSON {
    server = "0.0.0.0";
    server_port = 6666;
    method = "chacha20-ietf-poly1305";
    password = config.sops.placeholder.shadowsocks-pwd;
    fast_open = true;
    mode = "tcp_and_udp";
  };

  sops.templates.shadowsocks-config.group = "root";

  systemd.services.shadowsocks = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.shadowsocks-rust}/bin/ssserver -c ${config.sops.templates.shadowsocks-config.path}";
    };
  };
}
