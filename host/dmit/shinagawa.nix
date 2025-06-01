{ config, pkgs, lib, ... }: {
  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = [
        "103.117.103.126/24"
        "2403:18c0:1001:179:787a:20ff:fe99:43a5/64"
      ];
      Gateway = [
        "103.117.103.1"
        "2403:18c0:1001:179::1"
      ];
    };
  };

  # systemd.network.networks.ethernet-static-v6 = {
  #   matchConfig = {
  #     Name = "eth0";
  #   };
  #   networkConfig = {
  #     Address = "2403:18c0:1001:179:787a:20ff:fe99:43a5/64";
  #     Gateway = "2403:18c0:1001:179::1";
  #   };
  # };

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
