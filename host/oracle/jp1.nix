{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.hysteria
  ];

  programs.nix-ld.enable = true;
}
