{ self, pkgs, lib, config, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.auto-bangumi
  ];

  nixpkgs.config.allowUnsupportedSystem = true;

  networking.nftables.enable = lib.mkForce false;
}
