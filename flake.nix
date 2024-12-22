{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs";
    # nixpkgs.url = "github:NixOS/nixpkgs/pull/239721/head";
    # nixpkgs.url = "/root/nixpkgs";

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
      darwinConfigurations.M1 = import ./host/darwin/M1.nix { inherit self darwin; };
      darwinConfigurations.M4 = darwin.lib.darwinSystem { system = "aarch64-darwin"; modules = [ ./host/darwin/M4.nix ]; };
      darwinConfigurations.Macbook = darwin.lib.darwinSystem { system = "aarch64-darwin"; modules = [ ./host/darwin/Macbook.nix ]; };
      darwinConfigurations.github-action-darwin = darwin.lib.darwinSystem { system = "aarch64-darwin"; modules = [ ./host/darwin/github-action-darwin.nix ]; };
      nixosConfigurations = {

        utm-server = import ./host/utm/server.nix { inherit self nixpkgs secret home-manager; };

        # nix build .#nixosConfigurations.installer-aarch64.config.system.build.isoImage 
        # nix build .#nixosConfigurations.installer-x86_64.config.system.build.isoImage
        installer-x86_64 = import ./host/installer { arch = "x86_64";inherit self nixpkgs secret; };
        installer-aarch64 = import ./host/installer { arch = "aarch64";inherit self nixpkgs secret; };

        kexec-x86_64 = nixpkgs.lib.nixosSystem { modules = [ ./kexec { nixpkgs.hostPlatform = "x86_64-linux"; } ]; };
        kexec-aarch64 = nixpkgs.lib.nixosSystem { modules = [ ./kexec { nixpkgs.hostPlatform = "aarch64-linux"; } ]; };

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
          default = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin "test-vm" ''
            /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 8096 \
              -kernel ${self.nixosConfigurations.kexec-aarch64.config.system.build.kexec}/kernel  -initrd ${self.nixosConfigurations.kexec-aarch64.config.system.build.kexec}/initrd \
              -append "systemd.journald.forward_to_console systemd.set_credential_binary=github-private-key:''$(cat /Users/dominic/.ssh/test-base64) systemd.hostname=systemd-initrd" \
              -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
              -drive "file=disk.img,format=qcow2,if=virtio"  \
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
