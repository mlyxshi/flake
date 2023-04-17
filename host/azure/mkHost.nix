{ hostName, self, nixpkgs, home-manager, sops-nix, impermanence }:
nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    impermanence.nixosModules.impermanence
    home-manager.nixosModules.default
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    self.nixosModules.fileSystem
    self.nixosModules.settings.nixConfigDir
    self.nixosModules.settings.developerMode
    self.nixosModules.services.cloudflare-dns-sync
    self.nixosModules.services.nodestatus-client
    self.nixosModules.services.ssh-config
    ./hardware.nix
    ./x86_64/${hostName}.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = hostName;
      networking.domain = "mlyxshi.com";

      home-manager.users.root = import ../../home;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}
