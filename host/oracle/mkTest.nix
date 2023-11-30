{ arch, self, nixpkgs, sops-nix }:
nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    self.nixosModules.fileSystem.ext4
    self.nixosModules.services.ssh-config
    ./hardware.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "${arch}-linux";
      networking.hostName = "qemu-test-${arch}";
      networking.domain = "mlyxshi.com";
    }
  ];
  specialArgs = { inherit self nixpkgs sops-nix; };
}
