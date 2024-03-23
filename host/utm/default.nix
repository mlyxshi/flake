{ self, nixpkgs, secret, home-manager, plasma-manager, vpnconfinement }:

nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    #vpnconfinement.nixosModules.default
    self.nixosModules.home-manager
    self.nixosModules.os.nixos.desktop
    #self.nixosModules.network
    ./hardware.nix
    ./misc.nix
    ./vpn.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm";
      services.getty.autologinUser = "root";

      hardware.uinput.enable = true;
      users.groups.uinput.members =
        [ "dominic" ]; # uinput group owns the /uinput
      users.groups.input.members = [ "dominic" ]; # allow access to /dev/input

      home-manager.users.dominic = import ../../home/desktop.nix;
      home-manager.extraSpecialArgs = { inherit plasma-manager; };
    }
  ];
  specialArgs = { inherit self nixpkgs home-manager; };
}
