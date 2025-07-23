{ self, pkgs, lib, config, ... }: {
  # imports = [
  #   self.nixosModules.containers.podman
  # ];


  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  # '';  


  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    inbounds = [
      {
        type = "shadowsocks";
        listen = "0.0.0.0";
        listen_port = 8888;
        method = "aes-128-gcm";
        password = { _secret = "/secret/ss-password"; };
      }
    ];
  };
}
