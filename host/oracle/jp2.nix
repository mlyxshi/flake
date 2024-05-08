{ self, pkgs, lib, config, modulesPath, ... }: {
  imports = [
    # self.nixosModules.services.hysteria


    # self.nixosModules.services.transmission

    # self.nixosModules.containers.podman
    # self.nixosModules.containers.netboot-tftp

    # self.nixosModules.containers.navidrome
    # self.nixosModules.containers.change-detection
    # self.nixosModules.containers.baidunetdisk

    # "${modulesPath}/profiles/perlless.nix"
  ];

  system.switch.enable = false;
  system.etc.overlay.enable = true;
  systemd.sysusers.enable = true;
  boot.enableContainers = false;


  systemd.tmpfiles.settings."10-boot" =
    let
      efiArch = pkgs.stdenv.hostPlatform.efiArch;
    in
    {
      "/boot/EFI/BOOT".d = { };
      "/boot/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".C.argument = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

      "/boot/EFI/nixos/".d = { };
      "/boot/EFI/nixos/kernel.efi".C.argument = "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";
      "/boot/EFI/nixos/initrd.efi".C.argument = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";

      "/boot/loader/entries".d = { };
      "/boot/loader/entries/nixos.conf".C.argument = pkgs.writeText "nixos.conf" ''
        title NixOS
        linux /EFI/nixos/kernel.efi
        initrd /EFI/nixos/initrd.efi
        options init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}
      '';
    };
}
