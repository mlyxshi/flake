{ config, pkgs, lib, ... }: {
  networking.useNetworkd = true;
  networking.useDHCP = false; # Disable nixpkgs defined dhcp

  systemd.network.wait-online.anyInterface = true;
  systemd.network.networks.ethernet-default-dhcp = {
    matchConfig = { Name = [ "en*" "eth*" ]; };
    networkConfig = { DHCP = "yes"; };
  };


  networking.firewall.enable = false; # Disable nixpkgs defined firewall
  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      chain INPUT {
        # Drop all incoming traffic by default
        type filter hook input priority 0; policy drop;

        # Allow loopback traffic
        iifname lo accept

        # Allow ICMP
        ip protocol icmp accept

        # Accept traffic originated from us
        ct state {established, related} accept

        # Only Allow SSH and Traefik
        tcp dport { 22, 80, 443 } accept

        # Allow TFTP
        ${lib.optionalString (config.systemd.services ? tftpd) "udp dport 69 accept"}
        
        # Allow tuic
        ${lib.optionalString (config.systemd.services ? tuic) "udp dport 6666 accept"}

        # Allow snell
        ${lib.optionalString (config.systemd.services ? snell) "udp dport 7777 accept"}
        ${lib.optionalString (config.systemd.services ? snell) "tcp dport 7777 accept"}

        # Allow hysteria
        ${lib.optionalString (config.systemd.services ? hysteria) "udp dport 8888 accept"}
      }
    }
  '' + lib.optionalString (config.systemd.services ? hysteria) ''
    table inet HYSTERIA {
      chain PREROUTING {
        type nat hook prerouting priority 0; policy accept;

        # https://hysteria.network/docs/port-hopping/
        udp dport 40000-50000 redirect to :8888
      }
    }
  '';
}
