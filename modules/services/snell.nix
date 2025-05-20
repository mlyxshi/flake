{ config, pkgs, lib, ... }: {
  programs.nix-ld.enable = true;

  systemd.services.snell = {
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.snell}/bin/snell-server -c /secret/snell";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
