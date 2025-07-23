{ self, pkgs, lib, config, ... }: {
  # imports = [
  #   self.nixosModules.containers.podman
  # ];


  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  # '';  

  environment.systemPackages = with pkgs; [
    sing-box
  ];

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    dns = { };
    endpoints = [
      {
        type = "wireguard";
        tag = "wg-endpoint";
        address = [ "172.16.0.2/32" ];
        private_key = { _secret = "/secret/warp-allowed"; };
        listen_port = 10000;

        peers = [
          {
            address = "engage.cloudflareclient.com";
            port = 2408;
            public_key = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
            allowed_ips = [ "0.0.0.0/0" ];
          }
        ];
      }
    ];
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in-9999";
        listen = "0.0.0.0";
        listen_port = 9999;
        method = "aes-128-gcm";
        password = { _secret = "/secret/ss-password"; };
      }
      {
        type = "shadowsocks";
        tag = "ss-in-9998";
        listen = "0.0.0.0";
        listen_port = 9998;
        method = "aes-128-gcm";
        password = { _secret = "/secret/ss-password"; };
      }
    ];

    outbounds = [
      {
        type = "direct";
        tag = "direct-out";
      }
    ];

    route = {
      rules = [
        {
          inbound = "ss-in-9998";
          outbound = "wg-endpoint";
        }
      ];
    };
  };


}
