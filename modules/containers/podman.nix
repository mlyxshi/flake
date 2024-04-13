{ config, pkgs, lib, ... }: {

  virtualisation.podman.enable = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
  
  systemd.timers.podman-auto-update.wantedBy = [ "timers.target" ];
}
