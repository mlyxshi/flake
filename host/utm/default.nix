{ self, nixpkgs, sops-nix }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    self.nixosModules.fileSystem.repartd
    self.nixosModules.settings.developerMode
    self.nixosModules.services.ssh-config
    ./hardware.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm";
      settings.developerMode = true;

      # https://docs.getutm.app/guest-support/linux/#macos-virtiofs
      # share directory with macOS  
      fileSystems."/mnt" = {
        device = "share";
        fsType = "virtiofs";
      };

      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}
