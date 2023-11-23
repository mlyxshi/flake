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
      inherit (nixpkgs) lib;
      utils = import ./utils.nix nixpkgs;
      inherit (utils) mkFileHierarchyAttrset packagelist getArchPkgs oracle-serverlist azure-serverlist;
    in
    {
      overlays.default = final: prev: prev.lib.genAttrs packagelist (name: prev.callPackage ./pkgs/${name} { });
      nixosModules = mkFileHierarchyAttrset ./. "modules";
      darwinConfigurations.M1 = import ./host/M1 { inherit self nixpkgs darwin home-manager; };
      nixosConfigurations = {
        hx90 = import ./host/hx90 { inherit self nixpkgs home-manager sops-nix nix-index-database; };
        installer = import ./host/installer { inherit self nixpkgs sops-nix home-manager; };
        qemu-test-x64 = import ./host/oracle/mkTest.nix { inherit self nixpkgs sops-nix; };

        kexec-x86_64 = import ./kexec/mkKexec.nix { arch = "x86_64"; inherit self nixpkgs; };
        kexec-aarch64 = import ./kexec/mkKexec.nix { arch = "aarch64"; inherit self nixpkgs; };
      }
      // lib.genAttrs oracle-serverlist (hostName: import ./host/oracle/mkHost.nix { inherit hostName self nixpkgs home-manager sops-nix hydra; });

      packages.aarch64-darwin = lib.genAttrs (getArchPkgs "aarch64-darwin") (name: nixpkgs.legacyPackages.aarch64-darwin.callPackage ./pkgs/${name} { });
      packages.aarch64-linux = lib.genAttrs (getArchPkgs "aarch64-linux") (name: nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/${name} { });
      packages.x86_64-linux = lib.genAttrs (getArchPkgs "x86_64-linux") (name: nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/${name} { }) // {
        default = self.nixosConfigurations.kexec-x86_64.config.system.build.test;
        test0 = self.nixosConfigurations.kexec-x86_64.config.system.build.test0;
        sops-install-secrets = sops-nix.packages.x86_64-linux.sops-install-secrets;
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      devShells.aarch64-darwin.wrangler = import ./shells/wrangler.nix { pkgs = nixpkgs.legacyPackages.aarch64-darwin; };

      hydraJobs.aarch64 = self.nixosConfigurations.kexec-aarch64.config.system.build.kexec;
      hydraJobs.x86_64 = self.nixosConfigurations.kexec-x86_64.config.system.build.kexec;

      hydraJobs.sw2 = self.nixosConfigurations.sw2.config.system.build.toplevel;
    };
}
