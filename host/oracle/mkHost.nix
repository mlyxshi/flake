{ hostName, self, nixpkgs, sops-nix, home-manager, secret }:
let
  arch = if (builtins.pathExists ./aarch64/${hostName}.nix) then "aarch64" else "x86_64";
in
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    sops-nix.nixosModules.default
    self.nixosModules.home-manager
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    self.nixosModules.fileSystem.ext4
    self.nixosModules.services.nodestatus-client
    self.nixosModules.services.traefik
    self.nixosModules.services.telegraf
    self.nixosModules.services.ssh-config
    ./hardware.nix
    ./keep.nix
    ./${arch}/${hostName}.nix
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "${arch}-linux";
      networking.hostName = hostName;
      networking.domain = "mlyxshi.com";
    }
  ];
  specialArgs = { inherit self nixpkgs sops-nix home-manager; };
}
