{ hostName, self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.dhcp
    self.nixosModules.hardware.uefi.gpt-auto
    
    ./${hostName}.nix

    self.nixosModules.services.snell
    self.nixosModules.services.beszel-agent
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = hostName;
      services.getty.autologinUser = "root";
    }
  ];
  specialArgs = { inherit self; };
}
