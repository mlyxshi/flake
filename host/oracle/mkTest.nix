{ self, nixpkgs, sops-nix, impermanence }:
nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    impermanence.nixosModules.impermanence
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
