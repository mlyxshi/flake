{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.static
    self.nixosModules.hardware.bios.sda
    self.nixosModules.services.ss
    self.nixosModules.services.snell
    self.nixosModules.services.beszel-agent
    ./shinagawa.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "nrt";
    }
  ];
  specialArgs = { inherit self; };
}
