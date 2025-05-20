{ config, pkgs, lib, ... }: {
   boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_slow_start_after_idle" = 0; #https://www.kawabangga.com/posts/5217
  };

  # Always eth0
  boot.kernelParams = [ "net.ifnames=0" ];

  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  systemd.network.enable = true;
  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks.ethernet-static = {
    matchConfig = { 
      Name = "eth0"; 
    };
    networkConfig = { 
      Address = "103.117.103.126/24"; 
      Gateway = "103.117.103.1";
      DNS = "1.1.1.1";
    };
  };

  networking.firewall.enable = false;

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
