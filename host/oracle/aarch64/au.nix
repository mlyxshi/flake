{ self, config, pkgs, lib, ... }: {
  imports = [ self.nixosModules.services.prometheus ];


  networking.useNetworkd = lib.mkForce false;
  networking.useDHCP = lib.mkForce true;

}
