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

  systemd.services.vpn = {
    after = [ "network-online.target" ];
    before = [ "transmission.service" ];
    wants = [ "network-online.target" ];
    environment.WG_CONFIG_FILE = "/tmp/wg1.conf";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "transmission.sh" ''
        export PATH=$PATH:${pkgs.wireguard-tools}/bin:${pkgs.iproute2}/bin

        # Create a new network namespace
        ip netns add vpn
      
        # Create wireguard interface in host network namespace(get default route)
        # then move it to vpn network namespace
        ip link add wg1 type wireguard
        ip link set wg1 netns vpn

        # Add address to wireguard interface
        ADDRESS_LINE=$(grep "Address" $WG_CONFIG_FILE)
        ADDRESS=$(echo $ADDRESS_LINE | cut -d '=' -f 2| tr -d ' ')
        IFS=',' read -ra PARTS <<< "$ADDRESS"
        for PART in "''${PARTS[@]}"; do
          ip -n vpn a add $PART dev wg1
        done

        # Add wireguard configuration
        ip netns exec vpn wg setconf wg1 <(wg-quick strip $WG_CONFIG_FILE)

        # Up the interface
        ip -n vpn link set lo up
        ip -n vpn link set wg1 up

        # Add default route
        ip -n vpn route add default dev wg1
        ip -n vpn -6 route add default dev wg1
      '';

      ExecStopPost = "${pkgs.iproute2}/bin/ip netns del vpn";
    };

    wantedBy = [ "multi-user.target" ];
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
    serviceConfig.NetworkNamespacePath = "/run/netns/vpn";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.caddy-index = {
    after = [ "transmission.service" ];
    wantedBy = [ "multi-user.target" ];
    script = "${pkgs.caddy}/bin/caddy file-server --listen :8010 --root /var/lib/transmission/files --browse";
  };




}
