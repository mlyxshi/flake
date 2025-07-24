{ pkgs, lib, self, config, ... }:
let
  package = self.packages.${config.nixpkgs.hostPlatform.system}.snell;
in
{
  programs.nix-ld.enable = true;

  systemd.services.snell = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${package}/bin/snell-server -c /secret/snell";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.snell-warp = {
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${package}/bin/snell-server -c /secret/snell-warp";
      ExecStartPre = pkgs.writeShellScript "wireguard-up" ''
        export PATH=$PATH:${pkgs.wireguard-tools}/bin:${pkgs.iproute2}/bin
        ip link add wg1 type wireguard
        wg set wg1 listen-port 10000 private-key /secret/warp-allowed peer bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo= allowed-ips 0.0.0.0/0 endpoint engage.cloudflareclient.com:2408
        ip addr add 172.16.0.2/32 dev wg1
        ip link set wg1 up
      '';
      ExecStopPost = "${pkgs.iproute2}/bin/ip link del wg1";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
