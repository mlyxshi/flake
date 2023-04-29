{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.containers.podman
    self.nixosModules.containers.rsshub
    self.nixosModules.containers.change-detection
  ];

  networking.nftables.enable = lib.mkForce false;
}
