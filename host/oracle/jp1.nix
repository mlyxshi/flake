{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.tftp
    self.nixosModules.services.beszel-hub
    self.nixosModules.services.snell
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  systemd.services."komari-agent@llIhN2egiHfMivbc".overrideStrategy = "asDropin";
  systemd.services."komari-agent@llIhN2egiHfMivbc".wantedBy = [ "multi-user.target" ];

  # Oracle JP to US
  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  #   table ip REDIRECT {
  #     chain PREROUTING {
  #       type nat hook prerouting priority -100; policy accept;
  #       tcp dport 5555 dnat to 155.248.196.71:8888 
  #     }

  #     chain POSTROUTING {
  #       type nat hook postrouting priority 100; policy accept;
  #       tcp dport 8888 masquerade
  #     }
  #   }
  # '';
}
