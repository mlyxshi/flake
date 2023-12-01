{ arch, nixpkgs, self, sops-nix }:
nixpkgs.lib.nixosSystem {
  modules = [
    sops-nix.nixosModules.default
    self.nixosModules.os.nixos.server
    self.nixosModules.services.ssh-config
    ./configuration.nix
    {
      nixpkgs.hostPlatform = "${arch}-linux";
      networking.hostName = "installer";
      networking = {
        useNetworkd = true;
        useDHCP = true;
        firewall.enable = false;
      };
    }
  ];
  specialArgs = { inherit self nixpkgs; };
}
