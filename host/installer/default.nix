{ self, nixpkgs, sops-nix, home-manager }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.os.nixos.server
    self.nixosModules.settings.nixConfigDir
    self.nixosModules.settings.developerMode
    ./configuration.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "installer";
      networking = {
        useNetworkd = true;
        useDHCP = true;
        firewall.enable = false;
      };

      home-manager.users.root = import ../../home;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self nixpkgs sops-nix; };
}
