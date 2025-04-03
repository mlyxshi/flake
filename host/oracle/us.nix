{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.services.transmission
    self.nixosModules.services.snell
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  # Oracle US to JP(China Telecom to Oracle SJC via AS4134)
  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table ip REDIRECT {
      chain PREROUTING {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 1111 dnat to 138.3.223.82:5555
      }

      chain POSTROUTING {
        type nat hook postrouting priority 100; policy accept;
        ip daddr 138.3.223.82 tcp dport 5555 masquerade
      }
    }
  '';
}
