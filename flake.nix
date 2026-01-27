{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/pull/388231/head";
    # nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=master&shallow=1";
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable-small&shallow=1";

    darwin.url = "git+https://github.com/nix-darwin/nix-darwin.git?shallow=1";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    secret.url = "git+ssh://git@github.com/mlyxshi/secret.git?shallow=1";
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      secret,
    }:
    {
      darwinConfigurations = {
        M4 = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ ./host/darwin/M4.nix ];
        };
        Macbook = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ ./host/darwin/Macbook.nix ];
        };
      };
      nixosConfigurations = {
        # systemd-repart
        arm-init-sda-grow = nixpkgs.lib.nixosSystem { modules = [ ./host/init/arm.nix ]; };
        # bios test
        bios = nixpkgs.lib.nixosSystem { modules = [ ./host/init/bios.nix ]; };
        # Apple Silicon (M3 and later) supports nested virtualization via Apple's Hypervisor Framework for build nixos image require kvm
        utm = nixpkgs.lib.nixosSystem { modules = [ ./host/init/utm.nix ]; };

        initramfs-x86_64 = nixpkgs.lib.nixosSystem {
          modules = [
            ./initramfs
            { nixpkgs.hostPlatform = "x86_64-linux"; }
          ];
        };

        initramfs-aarch64 = nixpkgs.lib.nixosSystem {
          modules = [
            ./initramfs
            { nixpkgs.hostPlatform = "aarch64-linux"; }
          ];
        };
        
        nrt = import ./host/dmit { inherit self nixpkgs secret; };

        jp1 = import ./host/oracle/mkHost.nix {
          inherit self nixpkgs secret;
          hostName = "jp1";
        };

        jp2 = import ./host/oracle/mkHost.nix {
          inherit self nixpkgs secret;
          hostName = "jp2";
        };

        us = import ./host/oracle/mkHost.nix {
          inherit self nixpkgs secret;
          hostName = "us";
        };
      };

      nixosModules = nixpkgs.lib.packagesFromDirectoryRecursive {
        callPackage = path: _: path;
        directory = ./modules;
      };

      packages.x86_64-linux = {
        snell = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/snell/package.nix { };
      };

      packages.aarch64-linux = {
        commit-notifier = nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/commit-notifier.nix { };
        transmission = nixpkgs.legacyPackages.aarch64-linux.callPackage ./pkgs/transmission.nix { };
      };

      packages.aarch64-darwin = {
        default = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin "x86_64-initramfs-test" ''
          /opt/homebrew/bin/qemu-system-x86_64 -cpu qemu64 -nographic -m 4G \
            -kernel ${self.nixosConfigurations.initramfs-x86_64.config.system.build.kernel}/bzImage \
            -initrd ${self.nixosConfigurations.initramfs-x86_64.config.system.build.initialRamdisk}/initrd \
            -append "console=ttyS0 systemd.journald.forward_to_console root=fstab" \
            -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
            -device "virtio-scsi-pci,id=scsi0" -drive "file=disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
        '';

        arm-initramfs-test = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin "arm-initramfs-test" ''
          /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 4G \
            -kernel ${self.nixosConfigurations.initramfs-aarch64.config.system.build.kernel}/Image \
            -initrd ${self.nixosConfigurations.initramfs-aarch64.config.system.build.initialRamdisk}/initrd \
            -append "systemd.journald.forward_to_console root=fstab" \
            -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
            -device "virtio-scsi-pci,id=scsi0" -drive "file=disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
            -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd)
        '';
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
    };
}
