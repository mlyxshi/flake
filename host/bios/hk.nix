{ self, nixpkgs, home-manager }:
nixpkgs.lib.nixosSystem {
  modules = [
    home-manager.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network
    ./hardware.nix
    ./misc.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "hk";
      services.getty.autologinUser = "root";

      home-manager.users.root = import ../../home;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self home-manager; };
}
