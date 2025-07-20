{ pkgs, modulesPath, ... }: {

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
