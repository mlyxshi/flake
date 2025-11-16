{ config, pkgs, lib, self, ... }: {

  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "91.103.121.190/27";
      Gateway = "91.103.121.161";
    };
  };

  # Prefer IPv4 for DNS resolution
  networking.getaddrinfo.precedence."::ffff:0:0/96" = 100;

  systemd.services.komari-agent.environment = {
    AGENT_MONTH_ROTATE = "24";
    AGENT_INCLUDE_MOUNTPOINTS = "/";
  };
}
