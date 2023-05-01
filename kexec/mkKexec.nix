{ arch, nixpkgs, self }:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.strip
    ./host.nix
    ./build.nix
    ./initrd
    {
      nixpkgs.hostPlatform = "${arch}-linux";
    }
  ];
}
