# systemd-repartd: enlarge existing partitions
# systemd-growfs: enlarge filesystems in partitions

{ config, lib, pkgs, modulesPath, ... }:
let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in
{

  imports = [
    "${modulesPath}/image/repart.nix"
  ];

  fileSystems."/".autoResize = true;

  # https://www.freedesktop.org/software/systemd/man/latest/repart.d.html#Examples
  systemd.repart.enable = true;
  systemd.repart.partitions = {
    "01-root" = { Type = "root"; };
  };

  image.repart = {
    name = config.networking.hostName;
    partitions = {
      "BOOT" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
          "/EFI/nixos/kernel.efi".source = "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";
          "/EFI/nixos/initrd.efi".source = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
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
      "NIXOS" = {
        storePaths = [ config.system.build.toplevel ];
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

