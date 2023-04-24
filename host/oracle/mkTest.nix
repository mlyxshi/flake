{ self, nixpkgs, sops-nix, disko }:
nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    disko.nixosModules.disko
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    self.nixosModules.fileSystem
    self.nixosModules.settings.nixConfigDir
    self.nixosModules.settings.developerMode
    self.nixosModules.services.ssh-config
    ./hardware.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "qemu-test-x86_64";
      networking.domain = "mlyxshi.com";
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}
