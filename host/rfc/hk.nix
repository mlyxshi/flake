{ pkgs, modulesPath, ... }: {

  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "104.251.236.158/24";
      Gateway = "104.251.236.1";
    };
  };

  systemd.network.networks.ethernet-static-v6 = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "2403:18c0:1001:179:787a:20ff:fe99:43a5/64";
      Gateway = "2403:18c0:1001:179::1";
    };
  };

  # Port 22 for FCC
  services.openssh.ports = [ 2222 ];
}
