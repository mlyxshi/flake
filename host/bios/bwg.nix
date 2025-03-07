{ self, nixpkgs, secret, home-manager }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network
    ./hardware-sda.nix

    self.nixosModules.services.snell
    self.nixosModules.services.nodestatus-client
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "bwg";
      networking.domain = "mlyxshi.com";
      services.getty.autologinUser = "root";

      home-manager.users.root = import ../../home;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self home-manager; };
}
