{ self, nixpkgs, secret, home-manager}:
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
      networking.hostName = "utm-server";
      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self nixpkgs home-manager; };
}