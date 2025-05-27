{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.static
    self.nixosModules.services.ss
    self.nixosModules.hardware.bios.sda1
    
    ./shinagawa.nix
    
    self.nixosModules.services.snell  
    self.nixosModules.services.beszel-agent
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "nrt";
      networking.domain = "mlyxshi.com";
    }
  ];
  specialArgs = { inherit self; };
}
