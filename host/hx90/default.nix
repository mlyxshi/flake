{ self, nixpkgs, home-manager, sops-nix, nix-index-database }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    home-manager.nixosModules.default
    nix-index-database.nixosModules.nix-index
    self.nixosModules.os.nixos.desktop
    self.nixosModules.settings.developerMode
    self.nixosModules.services.ssh-config
    ./configuration.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "hx90";
      settings.developerMode = true;

      home-manager.users.root = import ../../home;
      home-manager.users.dominic = import ../../home/sway.nix;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self nixpkgs sops-nix; };
}
