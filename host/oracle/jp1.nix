{
  self,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.pocket-id
    self.nixosModules.services.snell
  ];

}
