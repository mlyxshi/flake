{ self, nixpkgs, darwin, home-manager }:

darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    home-manager.darwinModules.default
    self.nixosModules.os.darwin
    self.nixosModules.settings.nixConfigDir
    self.nixosModules.settings.developerMode
    {
      nixpkgs.overlays = [ self.overlays.default ];
      networking.hostName = "M1";

      settings.developerMode = true;
      settings.nixConfigDir = "/Users/dominic/flake";
      security.pam.enableSudoTouchIdAuth = true;

      home-manager.users.dominic = import ../../home/darwin.nix;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit nixpkgs; };
}


