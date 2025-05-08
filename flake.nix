{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/pull/388231/head";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    secret.url = "git+ssh://git@github.com/mlyxshi/secret";
  };

  outputs = { self, nixpkgs, darwin, secret }:
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

        utm-server = import ./host/utm/server.nix { inherit self nixpkgs secret; };

        # nix build .#nixosConfigurations.installer-aarch64.config.system.build.isoImage 
        # nix build .#nixosConfigurations.installer-x86_64.config.system.build.isoImage
        installer-x86_64 = import ./host/installer { arch = "x86_64";inherit self nixpkgs secret; };
        installer-aarch64 = import ./host/installer { arch = "aarch64";inherit self nixpkgs secret; };

        kexec-x86_64 = nixpkgs.lib.nixosSystem { modules = [ ./kexec { nixpkgs.hostPlatform = "x86_64-linux"; } ]; };
        kexec-aarch64 = nixpkgs.lib.nixosSystem { modules = [ ./kexec { nixpkgs.hostPlatform = "aarch64-linux"; } ]; };

      } 
      // lib.genAttrs oracle-serverlist (hostName: import ./host/oracle/mkHost.nix { inherit hostName self nixpkgs secret; })
      // lib.genAttrs ["gcp-hk" "gcp-tw" "gcp-jp"] (hostName: import ./host/gcp/mkHost.nix { inherit hostName self nixpkgs secret; });

      packages = {
        aarch64-darwin = lib.genAttrs (getArchPkgs "aarch64-darwin") (name: nixpkgs.legacyPackages.aarch64-darwin.callPackage ./pkgs/${name} { })
          // {
          # Test in Darwin
          default = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin "test-vm" ''
            /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 4G \
              -kernel ${self.nixosConfigurations.kexec-aarch64.config.system.build.kernel}/Image \
              -initrd ${self.nixosConfigurations.kexec-aarch64.config.system.build.initialRamdisk}/initrd \
              -append "systemd.journald.forward_to_console" \
              -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
              -device "virtio-scsi-pci,id=scsi0" -drive "file=disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
              -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd)
          '';
        };
        aarch64-linux = lib.genAttrs (getArchPkgs "aarch64-linux") (name: nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/${name} { });
        x86_64-linux = lib.genAttrs (getArchPkgs "x86_64-linux") (name: nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/${name} { }) // {
          # Test in Debian
          default = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "test-vm" ''
            qemu-system-x86_64 -accel kvm -cpu host -nographic -m 1G \
              -kernel ${self.nixosConfigurations.kexec-x86_64.config.system.build.kernel}/bzImage \
              -initrd ${self.nixosConfigurations.kexec-x86_64.config.system.build.initialRamdisk}/initrd \
              -append "systemd.journald.forward_to_console" \
              -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
              -device "virtio-scsi-pci,id=scsi0" -drive "file=disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
              -bios /usr/share/qemu/OVMF.fd
          '';
        };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixpkgs-fmt;
    };
}
