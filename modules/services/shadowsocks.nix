{ pkgs, lib, config, ... }: {

  age.secrets.shadowsocks-config = {
    file = ../../secrets/shadowsocks-config.age;
    mode = "444";
  };

  systemd.services.shadowsocks = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.shadowsocks-rust}/bin/ssserver -c ${config.age.secrets.shadowsocks-config.path}";
      DynamicUser = true;
    };
  };
}
