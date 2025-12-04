{
  self,
  nixpkgs,
  secret,
}:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.static
    self.nixosModules.hardware.bios.vda
    self.nixosModules.services.komari-agent
    ./misc.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "alice";
      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self; };
}
