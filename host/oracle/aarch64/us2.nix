{ self, config, pkgs, lib, vpnconfinement, ... }:
let
  peerPort = 60729; # https://airvpn.org/ports/
  settings = pkgs.writeText "settings.json" ''
    {
      "download-dir": "/var/lib/transmission/files",
      "rpc-whitelist-enabled": false,
      "rpc-authentication-required": true,
      "rpc-bind-address": "192.168.15.1", 
      "peer-port": ${toString peerPort},
      "port-forwarding-enabled": false,
      "utp-enabled": false
    }
  '';
in {
  imports = [ vpnconfinement.nixosModules.default ];

  networking.useNetworkd = lib.mkForce false;
  networking.useDHCP = lib.mkForce true;

  networking.firewall.enable = lib.mkForce true;
  networking.nftables.enable = lib.mkForce false;
  networking.firewall.allowedTCPPorts = [ 443 80 ];

  vpnnamespaces.wg = {
    enable = true;
    accessibleFrom = [ "192.168.0.0/24" ];
    wireguardConfigFile = "/tmp/wg0.conf";
    # allow host network namespace to access
    portMappings = [{
      from = 9091;
      to = 9091;
    }];
    # allow wireguard to access(vpn port forwarding)
    openVPNPorts = [{
      port = peerPort;
      protocol = "both";
    }];
  };

  systemd.services.transmission.vpnconfinement = {
    enable = true;
    vpnnamespace = "wg";
  };

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

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.transmission = {
          rule = "Host(`transmission-vpn.${config.networking.domain}`)";
          entryPoints = [ "websecure" "web" ];
          service = "transmission";
        };

        services.transmission.loadBalancer.servers =
          [{ url = "http://192.168.15.1:9091"; }];

        routers.transmission-vpn-index = {
          rule = "Host(`transmission-vpn-index.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "transmission-vpn-index";
        };

        services.transmission-vpn-index.loadBalancer.servers =
          [{ url = "http://127.0.0.1:8010"; }];
      };
    };
  };
}
