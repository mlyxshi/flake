{ self, nixpkgs, sops-nix }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    self.nixosModules.os.nixos.desktop
    self.nixosModules.network
    self.nixosModules.fileSystem.ext4
    self.nixosModules.services.ssh-config
    ./hardware.nix
    ({ pkgs, ... }: {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm-desktop";

      fileSystems."/mnt" = {
        device = "share";
        fsType = "virtiofs";
      };

      environment.systemPackages = with pkgs;[
      ];

    })
  ];
  specialArgs = { inherit self nixpkgs; };
}
