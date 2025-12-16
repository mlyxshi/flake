{
  hostName,
  self,
  nixpkgs,
  secret,
}:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.static
    self.nixosModules.hardware.bios.limine
    self.nixosModules.services.komari-agent
    ./${hostName}.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = hostName;
      # services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self; };
}