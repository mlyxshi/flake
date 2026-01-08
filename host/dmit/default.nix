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
    self.nixosModules.services.cloudflare-warp
    self.nixosModules.services.snell
    self.nixosModules.containers.podman
    self.nixosModules.containers.commit-notifier
    ./misc.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "nrt";
    }
  ];
  specialArgs = { inherit self; };
}
