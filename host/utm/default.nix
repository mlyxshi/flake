{ self, nixpkgs, sops-nix, home-manager, xremap }:

nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.os.nixos.desktop
    self.nixosModules.network
    self.nixosModules.fileSystem.ext4
    self.nixosModules.services.ssh-config
    ./hardware.nix
    ./misc.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "utm";
      services.getty.autologinUser = "root";

      hardware.uinput.enable = true;
      users.groups.uinput.members = [ "dominic" ];
      users.groups.input.members = [ "dominic" ];

      home-manager.sharedModules = [
        ../../home
      ];

      home-manager.extraSpecialArgs = {
        inherit xremap;
      };

      home-manager.users.dominic = import ../../home/desktop.nix;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}
