{ self, pkgs, lib, config, ... }: {
  imports = [ self.nixosModules.services.hydra.x86_64 ];
}
