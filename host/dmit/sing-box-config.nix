{
  log.level = "trace";
  inbounds = [
    {
      type = "shadowsocks";
      tag = "ss-in";
      listen = "0.0.0.0";
      listen_port = 9998;
      managed = true;
      method = "2022-blake3-aes-128-gcm";
      password = { _secret = "/secret/ss-password-2022"; };
    }
  ];
  endpoints = [
    {
      type = "wireguard";
      tag = "wg-endpoint";
      address = [ "172.16.0.2/32" "2606:4700:cf1:1000::1/128" ];
      private_key = { _secret = "/secret/warp-allowed"; };
      listen_port = 10000;
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
        rule_set = [
          "abematv"
          "dmm"
        ];
        outbound = "wg-endpoint";
      }
    ];

    rule_set = [
      {
        tag = "abematv";
        rules = {
          domain = [ "abema.tv" ];
          domain_suffix = [ "abema-tv.com" ];
          domain_keyword = [ "abematv" ];
        };
      }
      {
        tag = "dmm";
        rules = {
          domain_suffix = [ "dmm.com" "dmm.co.jp" "dmm-extension.com" ];
        };
      }
    ];

  };
  services = [
    {
      type = "ssm-api";
      servers = {
        "/" = "ss-in";
      };
      cache_path = "cache.json";
      listen = "0.0.0.0";
      listen_port = 6665;
    }
  ];
}


