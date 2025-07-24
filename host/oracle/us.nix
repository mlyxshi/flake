{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.transmission.default
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  systemd.services."komari-agent@JdkkZwkSx4r_k5GA".overrideStrategy = "asDropin";
  systemd.services."komari-agent@JdkkZwkSx4r_k5GA".wantedBy = [ "multi-user.target" ];

  # services.sing-box.enable = true;
  # services.sing-box.settings = {
  #   log.level = "info";
  #   inbounds = [
  #     {
  #       type = "shadowsocks";
  #       listen = "0.0.0.0";
  #       listen_port = 8888;
  #       method = "aes-128-gcm";
  #       password = { _secret = "/secret/ss-password"; };
  #     }
  #   ];
  # };

  programs.nix-ld.enable = true;

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
      with_gvisor
      with_quic
      with_dhcp
      with_wireguard
      with_utls
      with_acme
      with_clash_api
      with_tailscale
    ];

  });





  # Oracle US to JP(China Telecom to Oracle SJC via AS4134)
  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  #   table ip REDIRECT {
  #     chain PREROUTING {
  #       type nat hook prerouting priority -100; policy accept;
  #       tcp dport 1111 dnat to 138.3.223.82:5555
  #     }

  #     chain POSTROUTING {
  #       type nat hook postrouting priority 100; policy accept;
  #       ip daddr 138.3.223.82 tcp dport 5555 masquerade
  #     }
  #   }
  # '';
}
