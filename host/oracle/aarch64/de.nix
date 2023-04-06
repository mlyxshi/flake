{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.services.bangumi
  ];
}
