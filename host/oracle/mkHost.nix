{ hostName, self, nixpkgs, secret }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.hardware.uefi.gpt-auto
    self.nixosModules.network.dhcp
    self.nixosModules.services.beszel-agent
    self.nixosModules.services.traefik
    self.nixosModules.services.telegraf
    self.nixosModules.services.waste
    ./${hostName}.nix
    {
      nixpkgs.hostPlatform = "aarch64-linux";
      networking.hostName = hostName;
      networking.domain = "mlyxshi.com";
    }
  ];
  specialArgs = { inherit self; };
}
