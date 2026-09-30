{
  self,
  nixpkgs,
  secret,
  hostName,
}:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.hardware.bios.limine
    self.nixosModules.network.cloud-init

    self.nixosModules.services.komari-agent
    self.nixosModules.services.snell

    ./${hostName}.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "${hostName}";
    }
  ];
  specialArgs = { inherit self; };
}
