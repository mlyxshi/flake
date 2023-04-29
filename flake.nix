{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hydra.url = "github:NixOS/hydra";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, home-manager, sops-nix, hydra, nix-index-database }:
    let
      ls = dir: builtins.attrNames (builtins.readDir dir);
      pureName = pathList: map (path: nixpkgs.lib.strings.removeSuffix ".nix" path) pathList;
      mkModules = dir: nixpkgs.lib.genAttrs (pureName (ls ./modules/${dir})) (file: if nixpkgs.lib.sources.pathIsDirectory ./modules/${dir}/${file} then import ./modules/${dir}/${file} else import ./modules/${dir}/${file}.nix);
      
      oracle-arm64-serverlist = pureName (ls ./host/oracle/aarch64);
      oracle-x64-serverlist = pureName (ls ./host/oracle/x86_64);
      azure-x64-serverlist = pureName (ls ./host/azure/x86_64);
    in
    {
      overlays.default = import ./overlays;
      nixosModules = nixpkgs.lib.genAttrs (ls ./modules) (dir: mkModules dir);
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      darwinConfigurations.M1 = import ./host/M1 { inherit self nixpkgs darwin home-manager; };
      nixosConfigurations = {
        hx90 = import ./host/hx90 { inherit self nixpkgs home-manager sops-nix nix-index-database; };
        installer = import ./host/installer { inherit self nixpkgs sops-nix home-manager; };
        qemu-test-x64 = import ./host/oracle/mkTest.nix { inherit self nixpkgs sops-nix; };

        kexec-x86_64 = import ./kexec/mkKexec.nix { arch = "x86_64"; inherit nixpkgs; };
        kexec-aarch64 = import ./kexec/mkKexec.nix { arch = "aarch64"; inherit nixpkgs; };
      }
      // nixpkgs.lib.genAttrs (oracle-arm64-serverlist ++ oracle-x64-serverlist) (hostName: import ./host/oracle/mkHost.nix { inherit hostName self nixpkgs home-manager sops-nix hydra; })
      // nixpkgs.lib.genAttrs azure-x64-serverlist (hostName: import ./host/azure/mkHost.nix { inherit hostName self nixpkgs home-manager sops-nix; });

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

      packages.x86_64-linux.default = self.nixosConfigurations."kexec-x86_64".config.system.build.test;
      packages.x86_64-linux.test0 = self.nixosConfigurations."kexec-x86_64".config.system.build.test0;

      # hydra-create-user admin --password-prompt --role admin
      # Declarative spec file: hydra.json
      # Declarative input type: Git checkout
      # Declarative input value: https://github.com/mlyxshi/flake.git main 
      hydraJobs.aarch64 = self.nixosConfigurations."kexec-aarch64".config.system.build.kexec;
      hydraJobs.x86_64 = self.nixosConfigurations."kexec-x86_64".config.system.build.kexec;
    };
}
