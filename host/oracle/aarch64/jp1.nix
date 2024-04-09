{ self, pkgs, lib, config, home-manager, ... }: {
  disabledModules = [
    self.nixosModules.os.nixos.server
  ];
  
  imports = [ self.nixosModules.os.nixos.desktop ];

  home-manager.users.dominic = import ../../home/desktop.nix;
}
