{ arch, nixpkgs,}:
nixpkgs.lib.nixosSystem {
  modules = [
    ./host.nix
    ./build.nix
    ./initrd
    {
      nixpkgs.hostPlatform = "${arch}-linux";
    }
  ];
}
