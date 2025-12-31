{
  self,
  nixpkgs,
  secret,
  hostName
}:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network.cloud-init
    self.nixosModules.hardware.bios.limine
    self.nixosModules.services.komari-agent
    ./${hostName}.nix
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "${hostName}";
      # services.getty.autologinUser = "root";
      services.openssh.ports = [ 23333 ];
    }
  ];
  specialArgs = { inherit self; };
}