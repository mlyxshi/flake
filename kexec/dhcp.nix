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

  boot.initrd.systemd.network.networks.ethernet-default-dhcp = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
  };

}
