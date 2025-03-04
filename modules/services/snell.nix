{ config, pkgs, lib, ... }: {
  programs.nix-ld.enable = true;
  systemd.services.snell = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      ${pkgs.wget}/bin/wget https://dl.nssurge.com/snell/snell-server-v4.1.1-linux-amd64.zip
      ${pkgs.unzip}/bin/unzip snell-server-v4.1.1-linux-amd64.zip
    '';
    serviceConfig.ExecStart = "/var/lib/snell-server -c /secret/snell";
    serviceConfig.StateDirectory = "snell";
    serviceConfig.WorkingDirectory = "%S/snell";
  };
}
