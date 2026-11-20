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

  nixpkgs.hostPlatform = "x86_64-linux";
}
