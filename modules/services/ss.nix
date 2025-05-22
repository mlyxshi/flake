{ pkgs, lib, ... }: {
  systemd.services.ss = {
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.shadowsocks-rust}/bin/ssserver -c /secret/shadowsocks";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
