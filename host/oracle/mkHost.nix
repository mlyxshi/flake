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
    self.nixosModules.hardware.uefi.gpt-auto
    self.nixosModules.network.dhcp
    
    self.nixosModules.services.komari-agent
    ./${hostName}.nix
    {
      networking.hostName = "${hostName}";
      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self; };
}
