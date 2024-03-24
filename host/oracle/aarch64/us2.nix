{ self, config, pkgs, lib, vpnconfinement, ... }: 
let
settings = pkgs.writeText "settings.json" ''
  {
    "download-dir": "/var/lib/transmission/files",
    "rpc-whitelist-enabled": false,
    "rpc-authentication-required": true
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
      "10.0.0.0/24"
      "127.0.0.1"
    ];
    wireguardConfigFile = "/tmp/wg0.conf";
    portMappings = [
      { from = 9091; to = 9091; }
      { from = 5000; to = 5000; }
    ];
  };

 # Enable and specify VPN namespace to confine service in.
  systemd.services.transmission.vpnconfinement = {
    enable = true;
    vpnnamespace = "wg";
  };

  services.transmission = {
    enable = true;
    settings = {
      "rpc-bind-address" = "192.168.15.1"; # Bind RPC/WebUI to bridge address
    };
  }; 

  # users = {
  #   users.transmission = {
  #     group = "transmission";
  #     isNormalUser = true;
  #   };
  #   groups.transmission = { };
  # };

  # vpnnamespaces.wg = {
  #   enable = true;
  #   accessibleFrom = [
  #     "192.168.0.0/24"
  #   ];
  #   wireguardConfigFile = "/etc/secret/wg0.conf";
  #   portMappings = [
  #     # { from = 22; to = 22; } # tcp is default
  #     # { from = 22; to = 22; protocol = "tcp"; }
  #     # { from = 8080; to = 80; protocol = "udp"; }
  #     # { from = 443; to = 443; protocol = "both"; }
  #   ];
  # };

  # # Enable and specify VPN namespace to confine service in.

  # # services.transmission = {
  # #   enable = true;
  # #   settings = {
  # #     "rpc-bind-address" = "192.168.15.1"; # Bind RPC/WebUI to bridge address
  # #   };
  # # };

  # systemd.services.transmission-init = {
  #   unitConfig.ConditionPathExists = "!%S/transmission/settings.json";
  #   script = ''
  #     cat ${settings} > settings.json
  #   '';
  #   serviceConfig.User = "transmission";
  #   serviceConfig.Type = "oneshot";
  #   serviceConfig.StateDirectory = "transmission";
  #   serviceConfig.WorkingDirectory = "%S/transmission";
  #   wantedBy = [ "multi-user.target" ];
  # };

  # systemd.services.transmission = {
  #   after = [ "transmission-init.service" "network-online.target" ];
  #   wants = [ "network-online.target" ];
  #   environment = {
  #     TRANSMISSION_HOME = "%S/transmission";
  #     TRANSMISSION_WEB_HOME = "${pkgs.transmission}/public_html";
  #   };
  #   serviceConfig.User = "transmission";
  #   serviceConfig.EnvironmentFile = [ "/etc/secret/transmission" ];
  #   serviceConfig.ExecStart =
  #     "${pkgs.transmission}/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
  #   serviceConfig.WorkingDirectory = "%S/transmission";
  #   wantedBy = [ "multi-user.target" ];
  # };




}
