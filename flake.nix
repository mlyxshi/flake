{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

  outputs = { self, nixpkgs, darwin, home-manager, agenix, impermanence, hydra, nix-index-database }:
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

      packages.x86_64-linux.stdenv = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/stdenv { };
      packages.aarch64-linux.stdenv = nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/stdenv { };
      packages.aarch64-darwin.test = nixpkgs.legacyPackages.aarch64-darwin.callPackage ./pkgs/test { };
      packages.x86_64-linux.test = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/test { };

      devShells.aarch64-darwin.wrangler = import ./shells/wrangler.nix { pkgs = nixpkgs.legacyPackages."aarch64-darwin"; };

      # hydraJobs.test-x84 = nixpkgs.legacyPackages.x86_64-linux.runCommand "readme" { } ''
      #   echo hello world1!
      #   mkdir -p $out/
      #   echo "Hello world 1" > $out/readme
      # '';
      # hydraJobs.test-arm64 = nixpkgs.legacyPackages.aarch64-linux.runCommand "readme" { } ''
      #   echo hello world1!
      #   mkdir -p $out/
      #   echo "Hello world 1" > $out/readme
      # '';
    };
}
