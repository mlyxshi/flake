{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    self.nixosModules.services.transmission
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    inbounds = [
      {
        type = "anytls";
        tag = "anytls-in";
        listen = "0.0.0.0";
        listen_port = 8888;
        users = [
          {
            password = {
              _secret = "/secret/proxy-pwd";
            };
          }
        ];
        tls = {
          enabled = true;
          insecure = true;
        };
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
