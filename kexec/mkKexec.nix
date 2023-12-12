{ arch, nixpkgs }:
nixpkgs.lib.nixosSystem {
  modules = [
    ./host.nix
    ./build.nix
    ./initrd.nix
    {
      nixpkgs.hostPlatform = "${arch}-linux";
    }
  ];
}
