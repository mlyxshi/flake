{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.static
    self.nixosModules.hardware.bios.vda
    ./shinagawa.nix
    ./sing-box.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "nrt";
    }
  ];
  specialArgs = { inherit self; };
}
