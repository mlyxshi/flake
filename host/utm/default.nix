{ self, nixpkgs, sops-nix }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    self.nixosModules.os.nixos.desktop
    self.nixosModules.network
    self.nixosModules.fileSystem.ext4
    self.nixosModules.settings.developerMode
    self.nixosModules.services.ssh-config
    ./hardware.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm";
      settings.developerMode = true;
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}
