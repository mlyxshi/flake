{ self, pkgs, lib, config, ... }: {
  imports = [
    # web firewall
    self.nixosModules.services.hysteria
  ];

  networking.firewall.enable = lib.mkForce true;

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet HYSTERIA {
      chain PREROUTING {
        type nat hook prerouting priority dstnat; policy accept;

        # https://hysteria.network/docs/port-hopping/
        udp dport 50000-60000 redirect to :8888
      }
    }
  '';
}
