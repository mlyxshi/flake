{ config, pkgs, lib, ... }: {

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table ip REDIRECT {
      chain PREROUTING {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 5555 dnat to 47.242.243.176:8888 
        tcp dport 9999 dnat to 47.242.243.176:5201

        tcp dport 6666 dnat to 47.245.33.67:8888
      }

      chain POSTROUTING {
        type nat hook postrouting priority 100; policy accept;
        ip daddr 47.242.243.176 tcp dport 8888 masquerade
        ip daddr 47.242.243.176 tcp dport 5201 masquerade

        ip daddr 47.245.33.67 tcp dport 8888 masquerade
      }
    }
  '';

}
