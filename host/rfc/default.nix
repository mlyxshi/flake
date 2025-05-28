{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.static
    self.nixosModules.services.ss
    self.nixosModules.services.snell
    self.nixosModules.services.beszel-agent
    ./hk.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "rfc-hk";
    }
  ];
  specialArgs = { inherit self; };
}
