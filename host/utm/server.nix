{ self, nixpkgs, secret, home-manager }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    ./hardware.nix
    ./misc.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm-server";
      services.getty.autologinUser = "root";

      home-manager.users.root = import ../../home;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self home-manager; };
}
