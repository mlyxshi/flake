{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/pull/239721/head";

    secret.url = "git+ssh://git@github.com/mlyxshi/secret";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, home-manager, secret }:
    let
      inherit (nixpkgs) lib;
      utils = import ./utils.nix nixpkgs;
      inherit (utils) mkFileHierarchyAttrset packagelist getArchPkgs oracle-serverlist;
    in
    {
      overlays.default = final: prev: prev.lib.genAttrs packagelist (name: prev.callPackage ./pkgs/${name} { });
      nixosModules = mkFileHierarchyAttrset ./. "modules";
      darwinConfigurations.M4 = darwin.lib.darwinSystem { system = "aarch64-darwin"; modules = [ ./host/darwin/M4.nix ]; };
      darwinConfigurations.Macbook = darwin.lib.darwinSystem { system = "aarch64-darwin"; modules = [ ./host/darwin/Macbook.nix ]; };
      nixosConfigurations = {

        utm-server = import ./host/utm/server.nix { inherit self nixpkgs secret home-manager; };

        # nix build .#nixosConfigurations.installer-aarch64.config.system.build.isoImage 
        # nix build .#nixosConfigurations.installer-x86_64.config.system.build.isoImage
        installer-x86_64 = import ./host/installer { arch = "x86_64";inherit self nixpkgs secret; };
        installer-aarch64 = import ./host/installer { arch = "aarch64";inherit self nixpkgs secret; };

        kexec-x86_64 = nixpkgs.lib.nixosSystem { modules = [ ./kexec { nixpkgs.hostPlatform = "x86_64-linux"; } ]; };
        kexec-aarch64 = nixpkgs.lib.nixosSystem { modules = [ ./kexec { nixpkgs.hostPlatform = "aarch64-linux"; } ]; };

        hk = import ./host/bios/hk.nix { inherit self nixpkgs secret home-manager; };
        bwg = import ./host/bios/bwg.nix { inherit self nixpkgs secret home-manager; };

      } // lib.genAttrs oracle-serverlist (hostName: import ./host/oracle/mkHost.nix { inherit hostName self nixpkgs home-manager secret; });

      homeConfigurations = {
        darwin = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [ ./home/darwin.nix ];
          extraSpecialArgs = { inherit self; };
        };
        github-action = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home/github-action.nix ];
        };
      };

      packages = {
        aarch64-darwin = lib.genAttrs (getArchPkgs "aarch64-darwin") (name: nixpkgs.legacyPackages.aarch64-darwin.callPackage ./pkgs/${name} { })
          // {
          # https://wiki.gentoo.org/wiki/QEMU/Options
          default = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin "test-vm" ''
            /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu cortex-a57 -accel hvf -nographic -m 8G \
              -kernel ${self.nixosConfigurations.kexec-aarch64.config.system.build.kernel}/Image \
              -initrd ${self.nixosConfigurations.kexec-aarch64.config.system.build.initialRamdisk}/initrd \
              -append "systemd.journald.forward_to_console" \
              -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
              -device "virtio-scsi-pci,id=scsi0" -drive "file=disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
              -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd)
          '';
        };
        aarch64-linux = lib.genAttrs (getArchPkgs "aarch64-linux") (name: nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/${name} { });
        x86_64-linux = lib.genAttrs (getArchPkgs "x86_64-linux") (name: nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/${name} { });
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixpkgs-fmt;
    }; 
}
