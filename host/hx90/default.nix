{ self, nixpkgs, home-manager, sops-nix }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.os.nixos.desktop
    self.nixosModules.services.ssh-config
    ./configuration.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "hx90";
    }
  ];
  specialArgs = { inherit self nixpkgs sops-nix; };
}
