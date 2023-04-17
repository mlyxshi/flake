{ pkgs, lib, config, ... }: {

  sops.secrets.shadowsocks-config.mode = "444";

  systemd.services.shadowsocks = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.shadowsocks-rust}/bin/ssserver -c ${config.sops.secrets.shadowsocks-config.path}";
      DynamicUser = true;
    };
  };
}
