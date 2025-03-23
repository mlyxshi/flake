{ config, pkgs, lib, ... }: {
  services.uptime-kuma.enable = true;

  services.caddy.enable = true;
  services.caddy.extraConfig = ''
    :3001
    
    reverse_proxy :3001
  '';

}
