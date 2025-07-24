{ config, pkgs, lib, ... }: {

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
