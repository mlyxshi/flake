{ nixpkgs, self, secret }:
let
  inherit (nixpkgs) lib;
in
{
  modulesFromDirectoryRecursive = _dirPath:lib.packagesFromDirectoryRecursive {
    callPackage = path: _: import path;
    directory = _dirPath;
  };

  packagesSet-aarch64-linux = lib.packagesFromDirectoryRecursive {
    callPackage = nixpkgs.legacyPackages.aarch64-linux.callPackage;
    directory = ./pkgs;
  };

  packagesSet-x86_64-linux = lib.packagesFromDirectoryRecursive {
    callPackage = nixpkgs.legacyPackages.x86_64-linux.callPackage;
    directory = ./pkgs;
  };

  oracleNixosConfigurations = lib.packagesFromDirectoryRecursive {
    callPackage = path: _:nixpkgs.lib.nixosSystem {
      modules = [
        secret.nixosModules.default
        self.nixosModules.nixos.server
        self.nixosModules.hardware.uefi.gpt-auto
        self.nixosModules.network.dhcp
        self.nixosModules.services.komari-agent
        self.nixosModules.services.traefik
        self.nixosModules.services.telegraf
        self.nixosModules.services.waste
        path
        {
          nixpkgs.hostPlatform = "aarch64-linux";
          networking.hostName = lib.removeSuffix ".nix" (builtins.baseNameOf path);
          services.getty.autologinUser = "root";
        }
      ];
      specialArgs = { inherit self; };
    };
    directory = ./host/oracle;
  };


  kexec-test = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "kexec-test" ''
    qemu-system-x86_64 -accel kvm -cpu host -nographic -m 1G \
      -kernel ${self.nixosConfigurations.kexec-x86_64.config.system.build.kernel}/bzImage \
      -initrd ${self.nixosConfigurations.kexec-x86_64.config.system.build.initialRamdisk}/initrd \
      -append "systemd.journald.forward_to_console" \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -bios /usr/share/qemu/OVMF.fd
  '';


  darwin-kexec-test = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin "darwin-kexec-test" ''
    /opt/homebrew/bin/qemu-system-aarch64 -machine virt -cpu host -accel hvf -nographic -m 4G \
      -kernel ${self.nixosConfigurations.kexec-aarch64.config.system.build.kernel}/Image \
      -initrd ${self.nixosConfigurations.kexec-aarch64.config.system.build.initialRamdisk}/initrd \
      -append "systemd.journald.forward_to_console" \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
      -device "virtio-scsi-pci,id=scsi0" -drive "file=disk.img,if=none,format=qcow2,id=drive0" -device "scsi-hd,drive=drive0,bus=scsi0.0" \
      -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd)
  '';

}
