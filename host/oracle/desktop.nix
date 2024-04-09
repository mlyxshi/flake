{ self, nixpkgs, home-manager, secret, plasma-manager }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.home-manager
    self.nixosModules.os.nixos.desktop
    self.nixosModules.network
    self.nixosModules.services.nodestatus-client
    self.nixosModules.services.traefik
    self.nixosModules.services.telegraf
    ./hardware.nix
    ./keep.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "jp1";
      networking.domain = "mlyxshi.com";

      home-manager.users.dominic = import ../home/desktop.nix;
      home-manager.extraSpecialArgs = { inherit plasma-manager; };
    }
  ];
  specialArgs = { inherit self nixpkgs home-manager plasma-manager; };
}
