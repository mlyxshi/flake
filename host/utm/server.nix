{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.dhcp
    self.nixosModules.hardware.uefi.gpt-auto
    ./misc.nix
    {
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm";
      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self; };
}
