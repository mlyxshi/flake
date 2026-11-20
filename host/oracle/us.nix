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
    self.nixosModules.services.sing-box.default
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # services.sing-box-server.tor.enable = true;
}
