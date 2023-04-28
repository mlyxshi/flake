{ self, config, pkgs, lib, ... }: {
  imports = [
    self.nixosModules.container.podman
    self.nixosModules.container.rsshub
    self.nixosModules.container.change-detection
  ];

  networking.nftables.enable = lib.mkForce false;
}
