{ self, nixpkgs, sops-nix }:

nixpkgs.lib.nixosSystem {
  modules = [
    self.nixosModules.os.nixos.desktop
    self.nixosModules.settings.developerMode
    self.nixosModules.services.ssh-config
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm";
      settings.developerMode = true;
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}
