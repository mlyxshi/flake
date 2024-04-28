{ self, config, pkgs, lib, ... }:
let
  peerPort = 60729;
  pref = {
    download-dir = "/var/lib/transmission/files";
    rpc-whitelist-enabled = false;
    rpc-authentication-required = true;
    peer-port = peerPort;
    port-forwarding-enabled = false;
    utp-enabled = false;
  };
  settings = pkgs.writeText "settings.json" (builtins.toJSON pref);
in
{

  # I don't know why oracle ipv6 dhcp is not working under systemd-networkd
  # so use default old way to configure network 
  networking.useDHCP = lib.mkForce true;
  networking.dhcpcd.enable = lib.mkForce true;
  systemd.network.enable = lib.mkForce false;

  # https://airvpn.org/ports/
  # use port forwarding to access transmission web ui and transmission peer-port(easiest way)
  # See Better implementation(bridge/veth/firewall), https://github.com/Maroka-chan/VPN-Confinement
  systemd.services.vpn = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment.WG_CONFIG_FILE = "/secret/wireguard/us.conf";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "vpn-up" ''
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
    after = [ config.systemd.services.vpn.name ];
    bindsTo = [ config.systemd.services.vpn.name ];
    environment = {
      TRANSMISSION_HOME = "%S/transmission";
      TRANSMISSION_WEB_HOME = "${pkgs.transmission}/public_html";
    };
    serviceConfig.User = "transmission";
    serviceConfig.EnvironmentFile = [ "/secret/transmission" ];
    serviceConfig.ExecStart =
      "${pkgs.transmission}/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
    serviceConfig.WorkingDirectory = "%S/transmission";
    serviceConfig.NetworkNamespacePath = "/run/netns/vpn";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.caddy-index = {
    after = [ "transmission.service" ];
    wantedBy = [ "multi-user.target" ];
    script =
      "${pkgs.caddy}/bin/caddy file-server --listen :8010 --root /var/lib/transmission/files --browse";
  };

  services.traefik = {
    dynamicConfigOptions = {
      http = {
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
