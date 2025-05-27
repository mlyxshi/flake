{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.static
    ./hk.nix
    
    self.nixosModules.services.beszel-agent
    self.nixosModules.services.ss
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "rfc-hk";
    }
  ];
  specialArgs = { inherit self; };
}