{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.containers.podman
  ];

  virtualisation.oci-containers.containers.whmcs = {
    image = "docker.io/vpslog/vps-stock-monitor";
    volumes = [ "/var/lib/whmcs:/app/data" ];
    ports = [ "5000:5000" ];
    extraOptions = lib.concatMap (x: [ "--label" x ]) [
      "io.containers.autoupdate=registry"
    ];
  };


  # boot.kernel.sysctl = {
  #   "net.ipv6.conf.all.forwarding" = 1;
  # };

  # networking.nftables.enable = true;
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
