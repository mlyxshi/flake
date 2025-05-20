{ self, pkgs, lib, config, ... }: {
  imports = [
  ];

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  #   table ip6 REDIRECT {
  #     chain PREROUTING {
  #       type nat hook prerouting priority -100; policy accept;
  #       tcp dport 8080 dnat to [2a14:67c0:306:7d::a]:8888
  #     }
  #     chain POSTROUTING {
  #       type nat hook postrouting priority 100; policy accept;
  #       tcp dport 8888 masquerade
  #     }
  #   }
  # '';  

}
