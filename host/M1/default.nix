{ self, nixpkgs, darwin }:

darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    self.nixosModules.os.darwin
    self.nixosModules.settings.developerMode
    {
      nixpkgs.overlays = [
        self.overlays.default
      ];
      networking.hostName = "M1";
      settings.developerMode = true;
      security.pam.enableSudoTouchIdAuth = true;
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}


