{
  log.level = "info";
  inbounds = [
    {
      type = "shadowsocks";
      tag = "ss-in";
      listen = "0.0.0.0";
      listen_port = 9998;
      network = "tcp";
      method = "2022-blake3-aes-128-gcm";
      password = { _secret = "/secret/ss-password-2022"; };
      multiplex = { enabled = true; };
      managed = true;
    }
  ];
  endpoints = [
    {
      type = "wireguard";
      tag = "warp";
      address = [ "172.16.0.2/32" "2606:4700:cf1:1000::1/128" ];
      private_key = { _secret = "/secret/warp-allowed"; };
      peers = [
        {
          address = "engage.cloudflareclient.com";
          port = 2408;
          public_key = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
          allowed_ips = [ "0.0.0.0/0" "::/0" ];
          reserved = [ 129 120 123 ];
        }
      ];
    }
  ];
  route = {
    rules = [
      {
        inbound = "ss-in";
        rule_set = [ "abematv" "dmm" ]; # Cloudflare Warp for Unlock Japan Residential Service
        outbound = "warp";
      }
    ];

    rule_set = [
      {
        tag = "abematv";
        rules = [{
          domain = [ "abema.tv" ];
          domain_suffix = [ "abema-tv.com" ];
          domain_keyword = [ "abematv" ];
        }];
      }
      {
        tag = "dmm";
        rules = [{ domain_suffix = [ "dmm.com" "dmm.co.jp" "dmm-extension.com" ]; }];
      }
    ];

  };
  services = [
    {
      type = "ssm-api";
      servers = { "/" = "ss-in"; };
      cache_path = "cache.json";
      listen = "0.0.0.0";
      listen_port = 6665;
    }
  ];
}


