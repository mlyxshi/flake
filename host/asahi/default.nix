{ self, nixpkgs, sops-nix, nixos-apple-silicon }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    self.nixosModules.os.nixos.desktop
    #self.nixosModules.network
    #self.nixosModules.fileSystem.ext4
    self.nixosModules.services.ssh-config
    nixos-apple-silicon.nixosModules.default
    ./hardware.nix
    ./configuration.nix
  ];
  specialArgs = { inherit self nixpkgs nixos-apple-silicon; };
}
