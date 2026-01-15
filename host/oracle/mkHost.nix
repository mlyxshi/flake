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
    self.nixosModules.services.traefik
    self.nixosModules.services.telegraf
    ./${hostName}.nix
    {
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = "${hostName}";
      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self; };
}
