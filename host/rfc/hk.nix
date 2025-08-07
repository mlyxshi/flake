{ config, pkgs, lib, self, modulesPath, ... }:
let
  package = self.packages.${config.nixpkgs.hostPlatform.system}.komari-agent;
in
{
  systemd.network.networks.ethernet-static = {
    matchConfig = {
      Name = "eth0";
    };
    networkConfig = {
      Address = "104.251.236.158/24";
      Gateway = "104.251.236.1";
    };
  };

  # Port 22 for FCC
  services.openssh.ports = [ 2222 ];

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in";
        listen = "0.0.0.0";
        listen_port = 22;
        network = "tcp";
        method = "2022-blake3-aes-128-gcm";
        password = { _secret = "/secret/ss-password-2022"; };
        multiplex = { enabled = true; };
      }
    ];
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ct state {established, related} accept
        tcp dport { 22, 2222, 5201, 8888, 9999 } accept
        udp dport { 22, 5201, 8888, 9999 } accept
      }
    }
  '';

  systemd.services."komari-agent" = {
    after = [ "network.target" ];
    path = [ pkgs.vnstat ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${package}/bin/komari-agent -e https://top.mlyxshi.com -t xuDvEGZHYrkMITBA  --disable-web-ssh --disable-auto-update  --month-rotate 20 --include-nics eth0 --include-mountpoint /";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.vnstat.enable = true;
}
