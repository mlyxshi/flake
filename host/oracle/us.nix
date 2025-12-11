{
  self,
  config,
  pkgs,
  lib,
  ...
}:
# let
#   package = self.packages.${config.nixpkgs.hostPlatform.system}.sing-box;
# in
{
  imports = [
    self.nixosModules.services.transmission.default
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  services.sing-box.enable = true;
  # services.sing-box.package = package;
  services.sing-box.settings = {
    log.level = "info";
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in";
        listen = "0.0.0.0";
        listen_port = 8888;
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
        type = "anytls";
        tag = "anytls-in";
        listen = "0.0.0.0";
        listen_port = 9999;
        users = [
          {
            password = {
              _secret = "/secret/ss-password-2022";
            };
          }
        ];
      }
    ];
  };

  # systemd.services.cloudflare-warp-daemon = {
  #   after = [ "network.target" ];
  #   serviceConfig.ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
  #   serviceConfig.StateDirectory = "cloudflare-warp";
  #   wantedBy = [ "multi-user.target" ];
  # };

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
