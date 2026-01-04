{
  config,
  pkgs,
  lib,
  ...
}:
{

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };

  # Disable nixpkgs defined dhcp
  networking.useDHCP = false;

  systemd.network.enable = true;
  # systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
  systemd.network.wait-online.anyInterface = true;

  # Disable nixpkgs defined firewall
  # enable firewall by cloud provider web console
  networking.firewall.enable = false;
}
