{
  log = {
    level = "info";
    timestamp = true;
  };

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

  outbounds = [
    {
      type = "direct";
      tag = "direct-out";
    }
    {
      type = "socks";
      tag = "warp";
      server = "127.0.0.1";
      server_port = 40000;
      version = "5";
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

    final = "direct-out";

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


