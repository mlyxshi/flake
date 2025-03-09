{ hostName, self, nixpkgs, home-manager, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network
    #self.nixosModules.services.nezha
    self.nixosModules.services.traefik
    self.nixosModules.services.telegraf
    ./hardware.nix
    ./keep.nix
    ./${hostName}.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = hostName;
      networking.domain = "mlyxshi.com";

      home-manager.users.root = import ../../home;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self; };
}
