{ self, nixpkgs, secret, home-manager }:
nixpkgs.lib.nixosSystem {
  modules = [
    secret.nixosModules.default
    home-manager.nixosModules.default
    self.nixosModules.nixos.server
    self.nixosModules.network
    ./hardware.nix

    # self.nixosModules.services.nodestatus-client
    {
      nixpkgs.overlays = [ self.overlays.default ];
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "dmit";
      networking.domain = "mlyxshi.com";
      services.getty.autologinUser = "root";

      home-manager.users.root = import ../../home;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.verbose = true;


      programs.nix-ld.enable = true; # snell
      systemd.services.snell = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "snell-server -c /secret/snell";
        serviceConfig.StateDirectory = "snell";
        serviceConfig.WorkingDirectory = "%S/snell";
      };
    }
  ];
  specialArgs = { inherit self home-manager; };
}
