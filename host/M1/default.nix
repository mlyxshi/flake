{
  self,
  nixpkgs,
  darwin,
}:

darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    self.nixosModules.os.darwin
    {
      nixpkgs.overlays = [ self.overlays.default ];
      networking.hostName = "M1";
      security.pam.enableSudoTouchIdAuth = true;
    }
  ];
  specialArgs = {
    inherit self nixpkgs;
  };
}
