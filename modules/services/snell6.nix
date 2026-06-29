{
  pkgs,
  lib,
  self,
  ...
}:
{

  nixpkgs.overlays = [
    (final: prev: {
      snell6 = prev.callPackage (self + "/pkgs/snell6.nix") { };
    })
  ];

  systemd.services.snell = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${lib.getExe pkgs.snell6} -c /secret/snell6";
    wantedBy = [ "multi-user.target" ];
  };
}
