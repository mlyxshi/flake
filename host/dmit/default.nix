{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.dhcp
    self.nixosModules.hardware.bios.grub
    ./shinagawa.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "lax";
    }
  ];
  specialArgs = { inherit self; };
}