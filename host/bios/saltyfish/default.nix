{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    ./sjc.nix
    
    self.nixosModules.services.snell  
    self.nixosModules.services.beszel-agent
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "sjc";
      networking.domain = "mlyxshi.com";
    }
  ];
  specialArgs = { inherit self; };
}
