{ self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.dhcp
    ./hardware.nix
    ./misc.nix
    {
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm-server";
      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self; };
}
