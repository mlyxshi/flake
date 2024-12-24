{ arch, nixpkgs, self, secret, }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    self.nixosModules.nixos.server
    ./configuration.nix
    {
      nixpkgs.hostPlatform = "${arch}-linux";
      networking.hostName = "installer";
      networking = {
        useDHCP = true;
        firewall.enable = false;
      };
    }
  ];
  specialArgs = { inherit self; };
}
