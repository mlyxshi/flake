{
  log = {
    level = "info";
    timestamp = true;
  };

  inbounds = [
    {
      type = "shadowsocks";
      tag = "ss-in";
      listen = "::";
      listen_port = 443;
      network = "tcp";
      method = "2022-blake3-aes-128-gcm";
      password = { _secret = "/secret/ss-password-2022"; };
      multiplex = { enabled = true; };
      managed = true;
    }
    {
      type = "shadowsocks";
      tag = "ss-in-warp";
      listen = "::";
      listen_port = 9997;
      network = "tcp";
      method = "2022-blake3-aes-128-gcm";
      password = { _secret = "/secret/ss-password-2022"; };
      multiplex = { enabled = true; };
    }
  ];

  outbounds = [
    {
      type = "direct";
      tag = "DIRECT";
    }
    {
      type = "socks";
      tag = "WARP";
      server = "127.0.0.1";
      server_port = 40000;
      version = "5";
    }
  ];

  route = {
    rules = [
      {
        inbound = "ss-in";
        outbound = "DIRECT";
      }
      {
        inbound = "ss-in-warp";
        outbound = "WARP";
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


