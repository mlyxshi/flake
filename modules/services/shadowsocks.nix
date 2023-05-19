{ pkgs, lib, config, ... }: {

  sops.secrets.shadowsocks-pwd = { };

  sops.templates.shadowsocks-config.content = ''
    {
      "server":"0.0.0.0",
      "server_port":6666,
      "method":"aes-128-gcm",
      "password":"${config.sops.placeholder.shadowsocks-pwd}",
      "fast_open":true,
      "mode":"tcp_and_udp"
    }
  '';

  systemd.services.shadowsocks = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.shadowsocks-rust}/bin/ssserver -c ${config.sops.templates.shadowsocks-config.path}";
    };
  };
}
