{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    secret.url = "git+ssh://git@github.com/mlyxshi/secret";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs = { self, nixpkgs, darwin, home-manager, plasma-manager, secret }:
    let
      inherit (nixpkgs) lib;
      utils = import ./utils.nix nixpkgs;
      inherit (utils)
        mkFileHierarchyAttrset packagelist getArchPkgs oracle-serverlist;
    in {
      overlays.default = final: prev:
        prev.lib.genAttrs packagelist
        (name: prev.callPackage ./pkgs/${name} { });
      nixosModules = mkFileHierarchyAttrset ./. "modules";
      darwinConfigurations.M1 =
        import ./host/darwin/M1.nix { inherit self nixpkgs darwin; };
      darwinConfigurations.github-action-darwin = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./host/darwin/github-action-darwin.nix
        ];
      };
      nixosConfigurations = {
        utm-server = import ./host/utm/server.nix {
          inherit self nixpkgs secret home-manager;
        };

        utm-desktop = import ./host/utm/desktop.nix {
          inherit self nixpkgs home-manager plasma-manager secret;
        };

        jp1 = import ./host/oracle/desktop.nix {
          inherit self nixpkgs home-manager plasma-manager secret;
        };

        qemu-test-x86_64 = import ./host/oracle/mkTest.nix {
          arch = "x86_64";
          inherit self nixpkgs secret;
        };
        qemu-test-aarch64 = import ./host/oracle/mkTest.nix {
          arch = "aarch64";
          inherit self nixpkgs secret;
        };

        # nix build --no-link --print-out-paths github:mlyxshi/flake#nixosConfigurations.installer-aarch64.config.system.build.isoImage 
        # nix build --no-link --print-out-paths github:mlyxshi/flake#nixosConfigurations.installer-x86_64.config.system.build.isoImage
        installer-x86_64 = import ./host/installer {
          arch = "x86_64";
          inherit self nixpkgs secret;
        };
        installer-aarch64 = import ./host/installer {
          arch = "aarch64";
          inherit self nixpkgs secret;
        };

        kexec-x86_64 = nixpkgs.lib.nixosSystem {
          modules = [
            ./kexec/host.nix
            ./kexec/initrd.nix
            { nixpkgs.hostPlatform = "x86_64-linux"; }
          ];
        };

        kexec-aarch64 = nixpkgs.lib.nixosSystem {
          modules = [
            ./kexec/host.nix
            ./kexec/initrd.nix
            { nixpkgs.hostPlatform = "aarch64-linux"; }
          ];
        };
      } // lib.genAttrs oracle-serverlist (hostName:
        import ./host/oracle/mkHost.nix {
          inherit hostName self nixpkgs home-manager secret;
        });

      homeConfigurations = {
        darwin = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [ ./home/darwin.nix ];
          extraSpecialArgs = { inherit self; };
        };
        asahi = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          modules = [ ./home/asahi.nix ];
          extraSpecialArgs = { inherit plasma-manager self; };
        };
        deck = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home/deck.nix ];
          extraSpecialArgs = { inherit plasma-manager self; };
        };
        github-action = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home/github-action.nix ];
        };
      };

      packages = {
        aarch64-darwin = lib.genAttrs (getArchPkgs "aarch64-darwin") (name:
          nixpkgs.legacyPackages.aarch64-darwin.callPackage ./pkgs/${name} { })
          // {
            default = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin
              "test-vm" ''
                /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 2048 \
                    -kernel ${self.nixosConfigurations.kexec-aarch64.config.system.build.kexec}/Image  -initrd ${self.nixosConfigurations.kexec-aarch64.config.system.build.kexec}/initrd.zst \
                    -append "systemd.journald.forward_to_console" \
                    -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
                    -drive "file=disk.img,format=qcow2,if=virtio"  \
                    -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd)
              '';
          };
        aarch64-linux = lib.genAttrs (getArchPkgs "aarch64-linux") (name:
          nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/${name} { });
        x86_64-linux = lib.genAttrs (getArchPkgs "x86_64-linux") (name:
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/${name} { });
      };

      formatter.aarch64-darwin =
        nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      formatter.aarch64-linux =
        nixpkgs.legacyPackages.aarch64-linux.nixpkgs-fmt;

      hydraJobs = {
        kexec-x86_64 =
          self.nixosConfigurations.kexec-x86_64.config.system.build.kexec;
        kexec-aarch64 =
          self.nixosConfigurations.kexec-aarch64.config.system.build.kexec;
        transmission-aarch64 = self.packages.aarch64-linux.transmission;
      };

      apps = {
        x86_64-linux.deck-init = {
          type = "app";
          program = "${nixpkgs.legacyPackages.x86_64-linux.writeScript "init"
            (builtins.readFile ./run/deck-init.sh)}";
        };

        aarch64-linux.asahi-init = {
          type = "app";
          program = "${nixpkgs.legacyPackages.aarch64-linux.writeScript "init"
            (builtins.readFile ./run/asahi-init.sh)}";
        };
      };
    };
}
