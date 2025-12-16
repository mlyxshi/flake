{ self, nixpkgs }:
nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.nixos.server
    self.nixosModules.network.dhcp
    ./misc.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "lax-test";
    }
  ];
  specialArgs = { inherit self; };
}