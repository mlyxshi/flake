{ hostName, self, nixpkgs, home-manager, secret, vpnconfinement }:
let
  arch = if (builtins.pathExists ./aarch64/${hostName}.nix) then
    "aarch64"
  else
    "x86_64";
in nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.home-manager
    self.nixosModules.os.nixos.server
    self.nixosModules.network
    self.nixosModules.services.nodestatus-client
    self.nixosModules.services.traefik
    self.nixosModules.services.telegraf
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
  specialArgs = { inherit self nixpkgs home-manager vpnconfinement; };
}
