{ config, pkgs, lib, ... }: {
  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "103.117.103.126/24";
      Gateway = "103.117.103.1";
    };
    dns = [ "8.8.8.8" "1.1.1.1" ];
  };

  services.vnstat.enable = true;
  # Traffic Reset Date
  environment.etc."vnstat.conf".text = ''
    MonthRotate 24
    UnitMode 1
    Interface "eth0"
  '';

  systemd.services.traffic-api = {
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.python3}/bin/python ${./traffic.py}";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
