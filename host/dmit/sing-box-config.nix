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
