{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.containers.miniflux
  ];
  networking.nftables.enable = lib.mkForce false;
}
