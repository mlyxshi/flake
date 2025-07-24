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

  systemd.services.ssm = {
    after = [ "sing-box.service" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.python3}/bin/python ${./ssm.py}";
    };
  };

  systemd.timers.ssm = {
    timerConfig = {
      OnCalendar = "*:0/1"; # every minute
      AccuracySec = "1s";
    };
    wantedBy = [ "timers.target" ];
  };
}
