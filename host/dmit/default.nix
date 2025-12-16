{ self, nixpkgs }:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.nixos.server
    self.nixosModules.network.dhcp
    ./lax.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "lax";
    }
  ];
  specialArgs = { inherit self; };
}