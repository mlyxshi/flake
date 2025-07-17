{ pkgs, lib, self, config, ... }:
let
  package = self.packages.${config.nixpkgs.hostPlatform.system}.snell;
in
{
  programs.nix-ld.enable = true;

  systemd.services.snell-warp = {
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${package}/bin/snell-server -c /secret/snell-warp";
      ExecStartPre = pkgs.writeShellScript "wireguard-up" ''
        export PATH=$PATH:${pkgs.wireguard-tools}/bin:${pkgs.iproute2}/bin
        ip link add wg1 type wireguard
        wg setconf wg1 /secret/wireguard/warp-strip.conf
        ip addr add 172.16.0.2/32 dev wg1
        ip link set mtu 1280 dev wg1
        ip link set wg1 up
        wg setconf wg1 /secret/wireguard/warp-strip.conf
        resolvectl dns wg1 1.1.1.1
      '';
      ExecStopPost = "${pkgs.iproute2}/bin/ip link del wg1";
    };
    wantedBy = [ "multi-user.target" ];
  };

}

