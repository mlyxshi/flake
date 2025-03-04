{ config, pkgs, lib, ... }: {
  programs.nix-ld.enable = true;
  
  systemd.services.snell = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      if [ ! -f /var/lib/snell/snell-server ]; then
        ${pkgs.wget}/bin/wget https://dl.nssurge.com/snell/snell-server-v4.1.1-linux-amd64.zip
        ${pkgs.unzip}/bin/unzip snell-server-v4.1.1-linux-amd64.zip
      fi
    '';
    serviceConfig.ExecStart = "/var/lib/snell/snell-server -c /secret/snell";
    serviceConfig.StateDirectory = "snell";
    serviceConfig.WorkingDirectory = "%S/snell";
  };


}
