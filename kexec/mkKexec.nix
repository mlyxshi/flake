{ arch, nixpkgs }:
let
  # nixosSystem = nixpkgs.lib.nixosSystem;
  nixosSystem = import (nixpkgs + "/nixos/lib/eval-config.nix");
in nixosSystem {

  modules = [
    ./host.nix
    ./build.nix
    ./initrd.nix
    { nixpkgs.hostPlatform = "${arch}-linux"; }
  ];
}
