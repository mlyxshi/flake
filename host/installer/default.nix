{ self, nixpkgs, sops-nix }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    self.nixosModules.os.nixos.server
    self.nixosModules.settings.developerMode
    ./configuration.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "installer";
      networking = {
        useNetworkd = true;
        useDHCP = true;
        firewall.enable = false;
      };
    }
  ];
  specialArgs = { inherit self nixpkgs sops-nix; };
}
