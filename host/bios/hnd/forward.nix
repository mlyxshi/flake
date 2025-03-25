{ config, pkgs, lib, ... }: {

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table ip REDIRECT {
      chain PREROUTING {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 5555 dnat to 138.3.223.82:8888 
      }

      chain POSTROUTING {
        type nat hook postrouting priority 100; policy accept;
        ip daddr 138.3.223.82 tcp dport 8888 masquerade
      }
    }
  '';

}
