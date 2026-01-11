{
  pkgs,
  lib,
  self,
  config,
  ...
}:
{

  nixpkgs.overlays = [
    (final: prev: {
      snell = prev.callPackage (self + "/pkgs/snell/package.nix") { };
    })
  ];

  systemd.services.snell = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${pkgs.snell}/bin/snell-server -c /secret/snell";
    wantedBy = [ "multi-user.target" ];
  };
}
