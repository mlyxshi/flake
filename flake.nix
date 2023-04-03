{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-network-pr.url = "github:NixOS/nixpkgs/pull/169116/head";

    hydra.url = "github:NixOS/hydra";
    impermanence.url = "github:nix-community/impermanence";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-network-pr, darwin, home-manager, agenix, impermanence, hydra, nix-index-database }:
    let
      oracle-arm64-serverlist = map (x: nixpkgs.lib.strings.removeSuffix ".nix" x) (builtins.attrNames (builtins.readDir ./host/oracle/aarch64));
      oracle-x64-serverlist = map (x: nixpkgs.lib.strings.removeSuffix ".nix" x) (builtins.attrNames (builtins.readDir ./host/oracle/x86_64));
      azure-x64-serverlist = map (x: nixpkgs.lib.strings.removeSuffix ".nix" x) (builtins.attrNames (builtins.readDir ./host/azure/x86_64));
    in
    {
      overlays.default = import ./overlays;
      nixosModules = import ./modules;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;

      darwinConfigurations.M1 = import ./host/M1 { inherit self nixpkgs darwin home-manager; };

      nixosConfigurations = {
        hx90 = import ./host/hx90 { inherit self nixpkgs home-manager agenix impermanence nix-index-database; };
        installer = import ./host/installer { inherit self nixpkgs agenix home-manager; };
        qemu-test-x64 = import ./host/oracle/mkTest.nix { inherit self nixpkgs agenix impermanence; };

        kexec-x86_64 = nixpkgs-network-pr.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./kexec/host.nix
            ./kexec/build.nix
            ./kexec/initrd
          ];
        };

        kexec-aarch64 = nixpkgs-network-pr.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./kexec/host.nix
            ./kexec/build.nix
            ./kexec/initrd
          ];
        };
      }
      // nixpkgs.lib.genAttrs (oracle-arm64-serverlist ++ oracle-x64-serverlist) (hostName: import ./host/oracle/mkHost.nix { inherit hostName self nixpkgs home-manager agenix hydra impermanence; })
      // nixpkgs.lib.genAttrs azure-x64-serverlist (hostName: import ./host/azure/mkHost.nix { inherit hostName self nixpkgs home-manager agenix impermanence; });

      packages.aarch64-darwin.Anime4k = nixpkgs.legacyPackages.aarch64-darwin.callPackage ./pkgs/anime4k { };
      packages.x86_64-linux.Anime4k = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/anime4k { };

      packages.x86_64-linux.nodestatus-client = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/nodestatus-client { };

      packages.x86_64-linux.PingFang = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/Fonts/PingFang { };
      packages.x86_64-linux.SF-Pro = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/Fonts/SF-Pro { };

      packages.x86_64-linux.transmission = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/transmission { };
      packages.aarch64-linux.transmission = nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/transmission { };

      packages.x86_64-linux.alist = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/alist { };
      packages.aarch64-linux.alist = nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/alist { };

      packages.x86_64-linux.stdenv = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/stdenv { };
      packages.aarch64-linux.stdenv = nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/stdenv { };
      packages.aarch64-darwin.test = nixpkgs.legacyPackages.aarch64-darwin.callPackage ./pkgs/test { };
      packages.x86_64-linux.test = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/test { };

      devShells.aarch64-darwin.wrangler = import ./shells/wrangler.nix { pkgs = nixpkgs.legacyPackages."aarch64-darwin"; };

      packages.x86_64-linux.default = self.nixosConfigurations."kexec-x86_64".config.system.build.test;
      packages.x86_64-linux.test0 = self.nixosConfigurations."kexec-x86_64".config.system.build.test0;

      # Declarative spec file: spec.json
      # Declarative input type: Git checkout
      # Declarative input value: https://github.com/mlyxshi/flake.git main 
      hydraJobs.aarch64 = self.nixosConfigurations."kexec-aarch64".config.system.build.kexec;
      hydraJobs.x86_64 = self.nixosConfigurations."kexec-x86_64".config.system.build.kexec;
    };
}
