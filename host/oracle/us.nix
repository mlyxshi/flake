{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{

  imports = [
    self.nixosModules.programs.vscode-ssh-remote
    self.nixosModules.services.snell

    self.nixosModules.services.sing-box
  ];



}
