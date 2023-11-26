{ config, lib, pkgs, modulesPath, ... }:
let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in
{

  imports = [
    "${modulesPath}/image/repart.nix"
  ];

  boot.initrd.systemd.repart.enable = true;
  boot.initrd.systemd.repart.device = "/dev/sda";

  image.repart = {
    name = "repart-image";
    partitions = {
      "BOOT" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
            "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

          "/loader/entries/nixos.conf".source = pkgs.writeText "nixos.conf" ''
            title NixOS
            linux /EFI/nixos/kernel.efi
            initrd /EFI/nixos/initrd.efi
            options init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}
          '';

          "/EFI/nixos/kernel.efi".source =
            "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";

          "/EFI/nixos/initrd.efi".source =
            "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
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

