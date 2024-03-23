{ config, pkgs, lib, ... }: {

  #environment.systemPackages = with pkgs; [  ];
  networking.useNetworkd = true;
  networking.useDHCP = false; # Disable nixpkgs defined dhcp

  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks.ethernet-default-dhcp = {
    matchConfig = { Name = [ "en*" "eth*" ]; };
    networkConfig = { DHCP = "yes"; };
  };

  networking.firewall.enable = false; # Disable nixpkgs defined firewall
  networking.nftables.enable = false;
  
  
  vpnnamespaces.wg = {
    enable = true;
    accessibleFrom = [
      "192.168.0.0/24"
    ];
    wireguardConfigFile = "/tmp/wg0.conf";
  };


  # users = {
  #   users.transmission = {
  #     group = "transmission";
  #     isNormalUser = true;
  #   };
  #   groups.transmission = { };
  # };

  # systemd.services.transmission-init = {
  #   unitConfig.ConditionPathExists = "!%S/transmission/settings.json";
  #   script = ''
  #     cat ${./settings.json} > settings.json
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
  #     ADMIN = "test";
  #     PASSWORD = "test";
  #   };
  #   serviceConfig.User = "transmission";
  #   serviceConfig.ExecStart =
  #     "${pkgs.transmission}/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
  #   serviceConfig.WorkingDirectory = "%S/transmission";
  #   wantedBy = [ "multi-user.target" ];
  # };

}
