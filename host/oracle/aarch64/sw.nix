{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.container.podman
    self.nixosModules.container.change-detection
    self.nixosModules.container.rsshub
    self.nixosModules.container.kms
  ];

  # change-detection do not work with nftables
  networking.nftables.enable = lib.mkForce false;
}
