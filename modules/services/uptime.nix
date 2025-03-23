{ config, pkgs, lib, ... }: {
  services.uptime-kuma.enable = true;

  services.caddy.enable = true;
  services.caddy.extraConfig = ''
    ${config.networking.hostName}-up.mlyxshi.com {
        reverse_proxy 127.0.0.1:3001
    }
  '';

}
