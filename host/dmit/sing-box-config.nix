{
  log.level = "info";
  inbounds = [
    {
      type = "shadowsocks";
      tag = "ss-in-basic";
      listen = "0.0.0.0";
      listen_port = 80;
      network = "tcp";
      method = "2022-blake3-aes-128-gcm";
      password = {
        _secret = "/secret/ss-password-2022";
      };
    }
    {
      type = "shadowsocks";
      tag = "ss-in-mux";
      listen = "0.0.0.0";
      listen_port = 443;
      network = "tcp";
      method = "2022-blake3-aes-128-gcm";
      password = {
        _secret = "/secret/ss-password-2022";
      };
      multiplex = {
        enabled = true;
      };
    }
    {
      type = "shadowsocks";
      tag = "ss-in-warp";
      listen = "0.0.0.0";
      listen_port = 444;
      network = "tcp";
      method = "2022-blake3-aes-128-gcm";
      password = {
        _secret = "/secret/ss-password-2022";
      };
      multiplex = {
        enabled = true;
      };
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
        inbound = [
          "ss-in-basic"
          "ss-in-mux"
        ];
        outbound = "DIRECT";
      }
      {
        inbound = "ss-in-warp";
        outbound = "WARP";
      }
    ];
  };
}
