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
      inherit (utils) mkFileHierarchyAttrset packagelist getArchPkgs oracle-serverlist;
    in
    {
      overlays.default = final: prev: prev.lib.genAttrs packagelist (name: prev.callPackage ./pkgs/${name} { });
      nixosModules = mkFileHierarchyAttrset ./. "modules";
      darwinConfigurations.M1 = import ./host/M1 { inherit self nixpkgs darwin; };
      nixosConfigurations = {
        hx90 = import ./host/hx90 { inherit self nixpkgs sops-nix nix-index-database; };

        utm-x86_64 = import ./host/utm { arch = "x86_64"; inherit self nixpkgs sops-nix; };
        utm-aarch64 = import ./host/utm { arch = "aarch64"; inherit self nixpkgs sops-nix; };

        qemu-test-x86_64 = import ./host/oracle/mkTest.nix { arch = "x86_64"; inherit self nixpkgs sops-nix; };
        qemu-test-aarch64 = import ./host/oracle/mkTest.nix { arch = "aarch64"; inherit self nixpkgs sops-nix; };

        installer-x86_64 = import ./host/installer { arch = "x86_64"; inherit self nixpkgs sops-nix; };
        installer-aarch64 = import ./host/installer { arch = "aarch64"; inherit self nixpkgs sops-nix; };

        kexec-x86_64 = import ./kexec/mkKexec.nix { arch = "x86_64"; inherit self nixpkgs; };
        kexec-aarch64 = import ./kexec/mkKexec.nix { arch = "aarch64"; inherit self nixpkgs; };
      }
      // lib.genAttrs oracle-serverlist (hostName: import ./host/oracle/mkHost.nix { inherit hostName self nixpkgs sops-nix hydra; });

      homeConfigurations = {
        darwin = home-manager.lib.homeManagerConfiguration { pkgs = nixpkgs.legacyPackages.aarch64-darwin; modules = [ ./home/darwin.nix ]; };
        sway = home-manager.lib.homeManagerConfiguration { pkgs = nixpkgs.legacyPackages.x86_64-linux; modules = [ ./home/sway.nix ]; };
      };

      packages = {
        aarch64-darwin = lib.genAttrs (getArchPkgs "aarch64-darwin") (name: nixpkgs.legacyPackages.aarch64-darwin.callPackage ./pkgs/${name} { });
        aarch64-linux = lib.genAttrs (getArchPkgs "aarch64-linux") (name: nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/${name} { }) // {
          default = self.nixosConfigurations.kexec-aarch64.config.system.build.test;
          test0 = self.nixosConfigurations.kexec-aarch64.config.system.build.test0;
        };
        x86_64-linux = lib.genAttrs (getArchPkgs "x86_64-linux") (name: nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/${name} { }) // {
          default = self.nixosConfigurations.kexec-x86_64.config.system.build.test;
          test0 = self.nixosConfigurations.kexec-x86_64.config.system.build.test0;
        };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;

      hydraJobs = {
        kexec-x86_64 = self.nixosConfigurations.kexec-x86_64.config.system.build.kexec;
        kexec-aarch64 = self.nixosConfigurations.kexec-aarch64.config.system.build.kexec;
        transmission = self.packages.aarch64-linux.transmission;
      };
    };
}
