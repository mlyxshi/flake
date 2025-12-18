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
    networkConfig = {
      Address = [
        "161.248.63.8/24"
        "2401:e4e0:100:8::a/128"
      ];
      Gateway = "161.248.63.1";
    };

    routes = [
      {
        Gateway = "2401:e4e0:100::1";
        GatewayOnLink = true; # Special config since gateway isn't in subnet
      }
    ];
  };

}