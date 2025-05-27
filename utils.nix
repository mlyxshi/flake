{ nixpkgs, self, secret }:
let
  inherit (nixpkgs) lib;
in
{
  modulesFromDirectoryRecursive = _dirPath:lib.packagesFromDirectoryRecursive {
    callPackage = path: _: import path;
    directory = _dirPath;
  };

  oracleNixosConfigurations = lib.packagesFromDirectoryRecursive {
    callPackage = path: _:nixpkgs.lib.nixosSystem {
      modules = [
        secret.nixosModules.default
        self.nixosModules.nixos.server
        self.nixosModules.hardware.uefi.gpt-auto
        self.nixosModules.network.dhcp
        self.nixosModules.services.beszel-agent
        self.nixosModules.services.traefik
        self.nixosModules.services.telegraf
        self.nixosModules.services.waste
        path
        {
          nixpkgs.hostPlatform = "aarch64-linux";
          networking.hostName = lib.removeSuffix ".nix" (builtins.baseNameOf path);
        }
      ];
      specialArgs = { inherit self; };
    };
    directory = ./host/oracle;
  };

}
