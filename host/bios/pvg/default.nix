{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network
    ../hardware-vda.nix
    
    ./forward.nix
    self.nixosModules.services.snell  
    self.nixosModules.services.beszel-agent
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "pvg";
      networking.domain = "mlyxshi.com";
      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self; };
}
