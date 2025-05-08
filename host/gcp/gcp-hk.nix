{ self, pkgs, lib, config, ... }: {
  imports = [
  ];


  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table ip6 REDIRECT {
      chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 5555 dnat to [2a14:67c0:306:7d::a]:8888
      }
    }
  '';

}
