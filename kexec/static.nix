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

  boot.initrd.systemd.network.networks.ethernet-static = {
    matchConfig.Name = "en*";
    networkConfig.Address = "154.12.190.105/32";
    routes = [
      {
        Gateway = "193.41.250.250";
        GatewayOnLink = true; # Special config since gateway isn't in subnet
      }
    ];
  };
}
