{ arch, nixpkgs }:
nixpkgs.lib.nixosSystem {
  modules =
    [ ./host.nix ./initrd.nix { nixpkgs.hostPlatform = "${arch}-linux"; } ];
}
