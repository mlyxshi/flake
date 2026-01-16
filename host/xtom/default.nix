{
  self,
  nixpkgs,
  secret,
}:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.hardware.bios.limine
    self.nixosModules.network.cloud-init
    self.nixosModules.services.snell
    ./misc.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "sjc";
    }
  ];
  specialArgs = { inherit self; };
}
