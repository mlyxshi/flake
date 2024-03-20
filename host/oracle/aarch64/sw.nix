{ self, config, pkgs, lib, ... }: {
  # portal enabled firewall
  networking.nftables.enable = lib.mkForce false;

  imports = [ self.nixosModules.containers.miniflux ];
}
