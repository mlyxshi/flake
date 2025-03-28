{ config, pkgs, lib, ... }: {
  nix.settings.substituters = lib.mkBefore [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table ip REDIRECT {
      chain PREROUTING {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 5555 dnat to 103.177.163.166:8888 
      }

      chain POSTROUTING {
        type nat hook postrouting priority 100; policy accept;
        ip daddr 103.177.163.166 tcp dport 8888 masquerade
      }
    }
  '';

}
