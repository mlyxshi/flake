{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.tftp
    self.nixosModules.services.hysteria
    self.nixosModules.services.beszel-hub
    self.nixosModules.services.snell
    self.nixosModules.containers.podman
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  # Oracle JP to US
  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table ip REDIRECT {
      chain PREROUTING {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 5555 dnat to 155.248.196.71:8888 
      }

      chain POSTROUTING {
        type nat hook postrouting priority 100; policy accept;
        ip daddr 155.248.196.71 tcp dport 8888 masquerade
      }
    }
  '';
}
