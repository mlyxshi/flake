{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/ba97b201-52ca-4a14-91b7-435cd2bb1498";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/03E1-1B17";
      fsType = "vfat";
      neededForBoot = true;
    };

  nixpkgs.hostPlatform = "aarch64-linux";


  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.timeout = 1;


  boot.initrd.systemd.services.asahi-vendor-firmware = {
    after = [ "initrd-fs.target" ];
    before = [ "initrd.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /sysroot/lib/firmware
      cd /sysroot/lib/firmware
      cat /sysroot/boot/vendorfw/firmware.cpio | ${pkgs.cpio}/bin/cpio -id --quiet --no-absolute-filenames
    '';
    requiredBy = [ "initrd-fs.target" ];
  };

  # Disable upstream firmware extraction
  hardware.asahi.extractPeripheralFirmware = false;
  # # This is friendly(pure) for flake users
  # hardware.firmware = [
  #   pkgs.asahi-firmware
  # ];

}
