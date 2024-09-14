{ pkgs, lib, config, ... }: {

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

  systemd.services.hysteria = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.hysteria}/bin/hysteria server -c /secret/hysteria/config.yaml";
    };
  };
}
