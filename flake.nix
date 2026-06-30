{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/pull/498754/head";
    # nixpkgs.url = "path:/Users/dominic/nixpkgs/";
    # nixpkgs.url = "git+https://github.com/mlyxshi/nixpkgs.git?ref=initrd-discard-references&shallow=1";

    # nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=master&shallow=1";
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable-small&shallow=1";

    nixpkgs-stable.url = "git+https://github.com/NixOS/nixpkgs.git?rev=4684fd6b0c01e4b7d99027a34c93c2e09ecafee2&shallow=1";

    darwin.url = "git+https://github.com/nix-darwin/nix-darwin.git?shallow=1";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    secret.url = "git+ssh://git@github.com/mlyxshi/secret.git?shallow=1";
  };

  # https://isabelroses.com/blog/custom-lib-nixossystem/
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
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

        builder = nixpkgs.lib.nixosSystem { modules = [ ./host/darwin/macos-builder.nix ]; };

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

        jp2 = import ./host/oracle/mkHost.nix {
          inherit self nixpkgs secret;
          hostName = "jp2";
        };

        us = import ./host/oracle/mkHost.nix {
          inherit self secret nixpkgs nixpkgs-stable;
          hostName = "us";
        };
      };

      nixosModules = nixpkgs.lib.packagesFromDirectoryRecursive {
        callPackage = path: _: path;
        directory = ./modules;
      };

      packages.aarch64-darwin = {

        qemu-x86_64-initramfs-test = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin "x86_64-initramfs-test" ''
          /opt/homebrew/bin/qemu-system-x86_64 -cpu qemu64 -nographic -m 1G \
            -kernel ${self.nixosConfigurations.initramfs-x86_64.config.system.build.kernel}/bzImage \
            -initrd ${self.nixosConfigurations.initramfs-x86_64.config.system.build.initialRamdisk}/initrd \
            -append "console=ttyS0 systemd.journald.forward_to_console root=fstab rd.systemd.break=pre-switch-root" \
            -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
            -device "virtio-scsi-pci,id=scsi0" -drive "file=/Users/dominic/flake/test/disk-scsi.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
            -device "virtio-blk-pci,drive=hd0" -drive "file=/Users/dominic/flake/test/disk-blk.img,if=none,format=qcow2,id=hd0"
        '';

        default = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin "aarch64-initramfs-test" ''
          /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 1G \
            -kernel ${self.nixosConfigurations.initramfs-aarch64.config.system.build.kernel}/Image \
            -initrd ${self.nixosConfigurations.initramfs-aarch64.config.system.build.initialRamdisk}/initrd \
            -append "systemd.journald.forward_to_console root=fstab rd.systemd.break=pre-switch-root" \
            -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
            -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd) \
            -device "virtio-scsi-pci,id=scsi0" -drive "file=/Users/dominic/flake/test/disk-scsi.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
            -device "virtio-blk-pci,drive=hd0" -drive "file=/Users/dominic/flake/test/disk-blk.img,if=none,format=qcow2,id=hd0"
        '';
      };
    };
}
