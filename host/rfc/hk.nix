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

  # Port 22 for FCC
  services.openssh.ports = [ 2222 ];
}
