{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  imports = [ ./default.nix ];

  # PLACEHOLDER will be replaced in Github Action based on input
  boot.initrd.systemd.network.networks.ethernet-static =
    self.nixosConfigurations.PLACEHOLDER.config.systemd.network.networks.ethernet-static;
}
