{ arch, self, nixpkgs, secret, }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    ./hardware.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "${arch}-linux";
      networking.hostName = "qemu-test-${arch}";
      networking.domain = "mlyxshi.com";
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}
