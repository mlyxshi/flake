{ self, nixpkgs, home-manager, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network
    self.nixosModules.services.nodestatus-client
    self.nixosModules.services.traefik
    self.nixosModules.services.telegraf
    ./hardware.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "hk";
      networking.domain = "mlyxshi.com";

      home-manager.users.root = import ../../home;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self; };
}
