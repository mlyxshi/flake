{ self, nixpkgs, secret, home-manager, plasma-manager }:

nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.home-manager
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    ./hardware.nix
    ./misc.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm";
      services.getty.autologinUser = "root";

      # hardware.uinput.enable = true;
      # users.groups.uinput.members =
      #   [ "dominic" ]; # uinput group owns the /uinput
      # users.groups.input.members = [ "dominic" ]; # allow access to /dev/input
    }
  ];
  specialArgs = { inherit self nixpkgs home-manager; };
}
