{
  pkgs,
  lib,
  self,
  config,
  ...
}:
let
  package = self.packages.${config.nixpkgs.hostPlatform.system}.snell;
in
{
  programs.nix-ld.enable = true;

  systemd.services.snell = {
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${package}/bin/snell-server -c /secret/snell";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
