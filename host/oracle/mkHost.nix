{ hostName, self, nixpkgs, home-manager, agenix, impermanence, hydra }:
let
  arch = if (builtins.readDir ./aarch64) ? "${hostName}.nix" then "aarch64" else "x86_64";
in
nixpkgs.lib.nixosSystem {
  modules = [
    agenix.nixosModules.default
    impermanence.nixosModules.impermanence
    home-manager.nixosModules.default
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    self.nixosModules.fileSystem
    self.nixosModules.settings.nixConfigDir
    self.nixosModules.settings.developerMode
    self.nixosModules.services.cloudflare-dns-sync
    self.nixosModules.services.nodestatus-client
    self.nixosModules.services.traefik
    self.nixosModules.services.telegraf
    self.nixosModules.services.ssh-config
    ./hardware.nix
    ./keep.nix
    ./${arch}/${hostName}.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "${arch}-linux";
      networking.hostName = hostName;
      networking.domain = "mlyxshi.com";

      home-manager.users.root = import ../../home;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self nixpkgs hydra; };
}
