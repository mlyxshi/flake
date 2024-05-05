{ self, nixpkgs, secret, home-manager, plasma-manager }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.os.nixos.desktop
    self.nixosModules.network
    ./hardware.nix
    ./misc.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm-desktop";
      services.getty.autologinUser = "root";

      hardware.uinput.enable = true;
      users.groups.uinput.members = [ "dominic" ]; # uinput group owns the /uinput
      users.groups.input.members = [ "dominic" ]; # allow access to /dev/input

      home-manager.users.root = import ../../home;
      home-manager.users.dominic = import ../../home/desktop.nix;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
      home-manager.extraSpecialArgs = { inherit plasma-manager; };
    }
  ];
  specialArgs = { inherit self home-manager; };
}
