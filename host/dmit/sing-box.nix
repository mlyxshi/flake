{ config, pkgs, lib, ... }: {
  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
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
            reserved = [ 129 120 123 ];
          }
        ];
      }
    ];
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in-share";
        listen = "0.0.0.0";
        listen_port = 9999;
        managed = true;
        method = "2022-blake3-aes-128-gcm";
        password = { _secret = "/secret/ss-password-2022"; };
      }
      {
        type = "shadowsocks";
        tag = "ss-in-me";
        listen = "0.0.0.0";
        listen_port = 8888;
        method = "aes-128-gcm";
        password = { _secret = "/secret/ss-password"; };
      }
    ];
    route = {
      rules = [
        {
          inbound = "ss-in-me";
          outbound = "wg-endpoint";
        }
      ];
    };
    services = [
      {
        type = "ssm-api";
        servers = {
          "/" = "ss-in-share";
        };
        cache_path = "cache.json";
        listen = "0.0.0.0";
        listen_port = 6666;
      }
    ];
  };

  services.sing-box.package = pkgs.sing-box.overrideAttrs (previousAttrs: {
    pname = previousAttrs.pname + "-beta";
    version = "2.12";
    src = pkgs.fetchFromGitHub {
      owner = "SagerNet";
      repo = "sing-box";
      rev = "66a767d083fd37b3cd071466636e645bfc96bc96";
      hash = "sha256-2R89tGf2HzPzcytIg7/HxbEP/aDMZ6MxZOk6Z8C1hZA=";
    };
    vendorHash = "sha256-tyGCkVWfCp7F6NDw/AlJTglzNC/jTMgrL8q9Au6Jqec=";

    tags = [
      "with_gvisor"
      "with_quic"
      "with_dhcp"
      "with_wireguard"
      "with_utls"
      "with_acme"
      "with_clash_api"
      "with_tailscale"
    ];

  });

  users = {
    users.sing-box = {
      group = "sing-box";
      isSystemUser = true;
    };
    groups.sing-box = { };
  };
}
