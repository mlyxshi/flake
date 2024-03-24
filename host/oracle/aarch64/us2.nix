{ self, config, pkgs, lib, vpnconfinement, ... }: 
let
settings = pkgs.writeText "settings.json" ''
  {
    "download-dir": "/var/lib/transmission/files",
    "rpc-whitelist-enabled": false,
    "rpc-authentication-required": true,
    "rpc-bind-address" = "192.168.15.1"
  }
'';
in
{
  imports = [
    vpnconfinement.nixosModules.default
  ];

  networking.firewall.enable = lib.mkForce true;
  networking.nftables.enable = lib.mkForce false;


  vpnnamespaces.wg = {
    enable = true;
    accessibleFrom = [
      "192.168.0.0/24"
    ];
    wireguardConfigFile = "/tmp/wg0.conf";
    portMappings = [
      { from = 9091; to = 9091; }
      { from = 51413; to = 51413; }
    ];
  };

 # Enable and specify VPN namespace to confine service in.
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


  systemd.services.transmission-init = {
    unitConfig.ConditionPathExists = "!%S/transmission/settings.json";
    script = ''
      cat ${settings} > settings.json
    '';
    serviceConfig.User = "transmission";
    serviceConfig.Type = "oneshot";
    serviceConfig.StateDirectory = "transmission";
    serviceConfig.WorkingDirectory = "%S/transmission";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.test-port = {
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.caddy}/bin/caddy file-server --listen :7777 --root /var/lib/transmission/files  --browse
    '';
  };

  systemd.services.test-port.vpnconfinement = {
    enable = true;
    vpnnamespace = "wg";
  };

  systemd.services.transmission = {
    after = [ "transmission-init.service" "network-online.target" ];
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

  networking.firewall.allowedTCPPorts = [ 443 80 ];

   services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.transmission = {
          rule = "Host(`transmission-vpn.${config.networking.domain}`)";
          entryPoints = [ "websecure" "web"];
          service = "transmission";
        };

        services.transmission.loadBalancer.servers =
          [{ url = "http://192.168.15.1:9091"; }];
      };
    };
  };
}
