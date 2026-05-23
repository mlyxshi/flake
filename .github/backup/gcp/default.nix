{
  self,
  nixpkgs,
  secret,
}:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.hardware.uefi.gpt-auto
    self.nixosModules.network.dhcp

    self.nixosModules.services.komari-agent
    ./misc.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "gcp";
    }
  ];
  specialArgs = { inherit self; };
}
