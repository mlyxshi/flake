{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{

  imports = [
    self.nixosModules.services.sing-box.default
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
}
