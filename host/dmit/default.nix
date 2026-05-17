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

    self.nixosModules.services.komari-agent
    self.nixosModules.services.warp-tor
    self.nixosModules.services.snell
    self.nixosModules.pr.traefik # remove when pr 490985 merged
    ./misc.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "nrt";
    }
  ];
  specialArgs = { inherit self; };
}
