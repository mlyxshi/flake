# systemd-repartd: enlarge existing partitions  (lsblk)
# systemd-growfs: enlarge filesystems in partitions (df -h)

{ config, lib, pkgs, modulesPath, ... }:
let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in
{

  imports = [
    "${modulesPath}/image/repart.nix"
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/BOOT";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/NIXOS";
    fsType = "ext4";
    # systemd-growfs
    autoResize = true;
  };

  # systemd-repartd
  # https://www.freedesktop.org/software/systemd/man/latest/repart.d.html#Examples
  systemd.repart.enable = true;
  systemd.repart.partitions = { "01-root" = { Type = "root"; }; };

  # OS raw image
  image.repart = {
    name = config.networking.hostName;
    partitions = {
      "00-esp" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
          "/EFI/nixos/kernel.efi".source = "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";
          "/EFI/nixos/initrd.efi".source = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
          "/EFI/systemd/systemd-boot${efiArch}.efi".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
          "/loader/entries/nixos.conf".source = pkgs.writeText "nixos.conf" ''
            title NixOS
            linux /EFI/nixos/kernel.efi
            initrd /EFI/nixos/initrd.efi
            options init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}
          '';
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          Label = "BOOT";
          SizeMinBytes = "1G";
        };
      };
      "01-root" = {
        storePaths = [ 
          config.system.build.toplevel 
          # has a context which refers to a complete source and binary closure
          # config.system.build.toplevel.drvPath 
        ];
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Label = "NIXOS";
          Minimize = "guess";
        };
      };
    };
  };

}
