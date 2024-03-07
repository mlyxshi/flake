{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./hardware.nix ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = false;
  };

  systemd.network.networks = {
    dhcp = {
      name = "eno1";
      DHCP = "yes";
    };
  };

  environment.systemPackages = [ pkgs.python3 ];
}
