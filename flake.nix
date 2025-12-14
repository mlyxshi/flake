{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/pull/388231/head";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=master&shallow=1";
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable&shallow=1";

    darwin.url = "git+https://github.com/nix-darwin/nix-darwin.git?shallow=1";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    secret.url = "git+ssh://git@github.com/mlyxshi/secret";
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      secret,
    }:
    let
      utils = import ./utils.nix { inherit self nixpkgs secret; };
      inherit (utils)
        modulesFromDirectoryRecursive
        packagesSet-x86_64-linux
        packagesSet-aarch64-linux
        oracleNixosConfigurations
        kexec-test
        darwin-kexec-test
        ;
    in
    {
      nixosModules = modulesFromDirectoryRecursive ./modules;
      darwinConfigurations.M4 = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./host/darwin/M4.nix ];
      };
      darwinConfigurations.Macbook = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./host/darwin/Macbook.nix ];
      };
      nixosConfigurations = {
        # make-disk-image
        bios-init-vda-static = nixpkgs.lib.nixosSystem { modules = [ ./host/init/bios-vda.nix ]; };
        bios-init-sda-static = nixpkgs.lib.nixosSystem { modules = [ ./host/init/bios-sda.nix ]; };

        # systemd-repart
        arm-init-sda-grow = nixpkgs.lib.nixosSystem { modules = [ ./host/init/arm.nix ]; };
        
        # Apple Silicon (M3 and later) supports nested virtualization via Apple's Hypervisor Framework for build nixos image(make-disk-image.nix)
        utm = nixpkgs.lib.nixosSystem { modules = [ ./host/init/utm.nix ]; };

        kexec-x86_64 = nixpkgs.lib.nixosSystem {
          modules = [
            ./kexec
            { nixpkgs.hostPlatform = "x86_64-linux"; }
          ];
        };
        kexec-aarch64 = nixpkgs.lib.nixosSystem {
          modules = [
            ./kexec
            { nixpkgs.hostPlatform = "aarch64-linux"; }
          ];
        };

        nrt = import ./host/dmit { inherit self nixpkgs secret; };
        jp3 = import ./host/alice/mkHost.nix { 
          inherit self nixpkgs secret; 
          hostName = "jp3";
        };
        
      }
      // oracleNixosConfigurations;

      packages.x86_64-linux = {
        default = kexec-test;
      }
      // packagesSet-x86_64-linux;
      packages.aarch64-linux = packagesSet-aarch64-linux;
      packages.aarch64-darwin.default = darwin-kexec-test;

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
    };
}
