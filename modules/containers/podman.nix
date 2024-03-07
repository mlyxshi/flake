{
  config,
  pkgs,
  lib,
  ...
}:
{

  virtualisation.podman.enable = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  # dummy code to activate podman-auto-update.timer to /etc/systemd/system/timers.target.wants/
  # so the podman-auto-update.timer status is now enabled
  systemd.timers.podman-auto-update.wantedBy = [ "timers.target" ];
}
