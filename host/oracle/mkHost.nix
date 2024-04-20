{ hostName, self, nixpkgs, home-manager, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.home-manager
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    self.nixosModules.services.nodestatus-client
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
    }
  ];
  specialArgs = { inherit self nixpkgs home-manager; };
}
