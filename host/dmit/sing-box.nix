{ config, pkgs, lib, ... }: {
  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in";
        listen = "0.0.0.0";
        listen_port = 9999;
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
        listen_port = 7777;
      }
    ];
  };

  services.sing-box.package = pkgs.sing-box.overrideAttrs (previousAttrs: {
    pname = previousAttrs.pname + "-beta";
    version = "66a767d083fd37b3cd071466636e645bfc96bc96";

    src = previousAttrs.src.override {
      hash = "";
    };

    vendorHash = "";
  });


}
