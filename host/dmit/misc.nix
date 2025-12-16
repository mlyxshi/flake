{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
{
  imports = [
    self.nixosModules.hardware.bios.limine
  ];

}
