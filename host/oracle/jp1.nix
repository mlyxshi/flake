{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.tftp
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  systemd.services."komari-agent@llIhN2egiHfMivbc".overrideStrategy = "asDropin";
  systemd.services."komari-agent@llIhN2egiHfMivbc".wantedBy = [ "multi-user.target" ];
}
