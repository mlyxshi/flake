{
  config,
  pkgs,
  lib,
  ...
}:
{

  imports = [
    ./default.nix
  ];

  systemd.network.networks.ethernet-default-dhcp = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
  };
}
