{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.pocket-id
  ];

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in";
        listen = "0.0.0.0";
        listen_port = 8888;
        network = "tcp";
        method = "2022-blake3-aes-128-gcm";
        password = { _secret = "/secret/ss-password-2022"; };
        multiplex = { enabled = true; };
      }
    ];
  };

  systemd.services.komari-agent.environment = {
    AGENT_MONTH_ROTATE = "1";
    AGENT_INCLUDE_MOUNTPOINTS = "/boot;/";
  };

}
