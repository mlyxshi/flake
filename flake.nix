{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/pull/388231/head";

    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    secret.url = "git+ssh://git@github.com/mlyxshi/secret";
  };

  outputs = { self, nixpkgs, darwin, secret }:
    let
      utils = import ./utils.nix { inherit self nixpkgs secret; };
      inherit (utils) modulesFromDirectoryRecursive packagesSet-x86_64-linux packagesSet-aarch64-linux oracleNixosConfigurations kexec-test darwin-kexec-test;
    in
    {
      nixosModules = modulesFromDirectoryRecursive ./modules;
      darwinConfigurations.M4 = darwin.lib.darwinSystem { system = "aarch64-darwin"; modules = [ ./host/darwin/M4.nix ]; };
      darwinConfigurations.Macbook = darwin.lib.darwinSystem { system = "aarch64-darwin"; modules = [ ./host/darwin/Macbook.nix ]; };
      nixosConfigurations = {

        utm = import ./host/utm/server.nix { inherit self nixpkgs secret; };

        # nix build .#nixosConfigurations.installer-aarch64.config.system.build.isoImage 
        # nix build .#nixosConfigurations.installer-x86_64.config.system.build.isoImage
        installer-x86_64 = import ./host/installer { arch = "x86_64";inherit self nixpkgs secret; };
        installer-aarch64 = import ./host/installer { arch = "aarch64";inherit self nixpkgs secret; };

        kexec-x86_64 = nixpkgs.lib.nixosSystem { modules = [ ./kexec { nixpkgs.hostPlatform = "x86_64-linux"; } ]; };
        kexec-aarch64 = nixpkgs.lib.nixosSystem { modules = [ ./kexec { nixpkgs.hostPlatform = "aarch64-linux"; } ]; };

        nrt = import ./host/dmit { inherit self nixpkgs secret; };
        gcp-hk = import ./host/gcp/mkHost.nix { inherit self nixpkgs secret; hostName = "gcp-hk"; };

      } // oracleNixosConfigurations;

      packages.x86_64-linux = { default = kexec-test; } // packagesSet-x86_64-linux;
      packages.aarch64-linux = packagesSet-aarch64-linux;
      packages.aarch64-darwin.default = darwin-kexec-test;
    };
}
