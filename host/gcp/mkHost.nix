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
    self.nixosModules.network.dhcp
    self.nixosModules.hardware.uefi.sda

    ./${hostName}.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = hostName;
      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self; };
}
