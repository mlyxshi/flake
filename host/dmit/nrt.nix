{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
{

  imports = [
    self.nixosModules.programs.vscode-ssh-remote
    self.nixosModules.services.sing-box.default
  ];

  services.sing-box-server.tor.enable = true;
  # services.sing-box-server.warp.enable = true;

  services.sing-box-server.settings = {
    inbounds = [
      {
        type = "anytls";
        tag = "anytls-in-us";
        listen = "0.0.0.0";
        listen_port = 9000;
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
      {
        type = "anytls";
        tag = "anytls-in-sw";
        listen = "0.0.0.0";
        listen_port = 9001;
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
    outbounds = [
      {
        type = "anytls";
        tag = "anytls-out-us";
        server = "155.248.196.71";
        server_port = 8888;
        password = {
          _secret = "/secret/proxy-pwd";
        };
        tls = {
          enabled = true;
          insecure = true;
        };
      }
      {
        type = "anytls";
        tag = "anytls-out-sw";
        server = "140.238.209.228";
        server_port = 8888;
        password = {
          _secret = "/secret/proxy-pwd";
        };
        tls = {
          enabled = true;
          insecure = true;
        };
      }
    ];

    route = {
      rules = [
        {
          action = "route";
          inbound = "anytls-in-us";
          outbound = "anytls-out-us";
        }
        {
          action = "route";
          inbound = "anytls-in-sw";
          outbound = "anytls-out-sw";
        }
      ];

    };
  };

  services.openssh.ports = [ 23333 ];

  boot.blacklistedKernelModules = [ "virtio_balloon" ];

  networking.nftables.enable = true;
  networking.nftables.tables.FIREWALL = {
    family = "inet";
    content = ''
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        ct state {established, related} accept
        tcp dport { 23333, 8888, 9000, 9001, 5201, 8010} accept
        udp dport { 5201, 8888, 9000, 9001 } accept
      }
    '';
  };

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";
}
