{ self, config, pkgs, lib, ... }: 
let
  peerPort = 60729; # https://airvpn.org/ports/
  settings = pkgs.writeText "settings.json" ''
    {
      "download-dir": "/var/lib/transmission/files",
      "rpc-whitelist-enabled": false,
      "rpc-authentication-required": true,
      "peer-port": ${toString peerPort},
      "port-forwarding-enabled": false,
      "utp-enabled": false
    }
'';
in {
  #imports = [ self.nixosModules.services.hysteria ];

  # I don't know why oracle ipv6 is not working under systemd-networkd
  # so use default old way to configure network 
  networking.useNetworkd = lib.mkForce false;
  networking.useDHCP = lib.mkForce true;

  networking.firewall.enable = lib.mkForce true;
  networking.nftables.enable = lib.mkForce false;
  networking.firewall.allowedTCPPorts = [ 443 80 ];

  users = {
    users.transmission = {
      group = "transmission";
      isNormalUser = true;
    };
    groups.transmission = { };
  };


  systemd.tmpfiles.settings."10-transmission" = {
    "/var/lib/transmission/".d = {
      user = "transmission";
      group = "transmission";
    };
    "/var/lib/transmission/files".d = {
      user = "transmission";
      group = "transmission";
    };
    "/var/lib/transmission/settings.json".C = {
      user = "transmission";
      group = "transmission";
      argument = "${settings}";
    };
  };

  systemd.services.transmission = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = {
      TRANSMISSION_HOME = "%S/transmission";
      TRANSMISSION_WEB_HOME = "${pkgs.transmission}/public_html";
    };
    serviceConfig.User = "transmission";
    serviceConfig.EnvironmentFile = [ "/etc/secret/transmission" ];
    serviceConfig.ExecStart =
      "${pkgs.transmission}/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
    serviceConfig.WorkingDirectory = "%S/transmission";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.caddy-index = {
    after = [ "transmission.service" ];
    wantedBy = [ "multi-user.target" ];
    script = "${pkgs.caddy}/bin/caddy file-server --listen :8010 --root /var/lib/transmission/files --browse";
  };




}
