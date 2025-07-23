{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.tftp
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  services.sing-box.enable = true;
  services.sing-box.settings = {
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in";
        listen = "0.0.0.0";
        listen_port = 8888;
        method = "aes-128-gcm";
        password = { _secret = "/secret/ss-password"; };
      }
    ];
  };

  systemd.services."komari-agent@llIhN2egiHfMivbc".overrideStrategy = "asDropin";
  systemd.services."komari-agent@llIhN2egiHfMivbc".wantedBy = [ "multi-user.target" ];
}
