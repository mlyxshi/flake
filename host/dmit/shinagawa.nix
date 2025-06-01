{ config, pkgs, lib, ... }: {
  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "103.117.103.126/24";
      Gateway = "103.117.103.1";
    };
  };

  networking.extraHosts = "2606:4700:4700::1001 api.twitter.com";

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
