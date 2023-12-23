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
      device = "/dev/nvme0n1p5";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/nvme0n1p4";
      fsType = "vfat";
      neededForBoot = true;
    };

  nixpkgs.hostPlatform = "aarch64-linux";


  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.timeout = 1;

  boot.extraModprobeConfig = ''
   options hid_apple swap_ctrl_cmd=1
  '';

  boot.initrd.systemd.extraBin = {
    cpio = "${pkgs.cpio}/bin/cpio";
  };

  boot.initrd.systemd.services.asahi-vendor-firmware = {
    after = [ "initrd-fs.target" ];
    before = [ "initrd.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      [ -e /sysroot/lib/firmware ] && rm -rf /sysroot/lib/firmware
      mkdir -p /sysroot/lib/firmware  /tmp/.fwsetup/
      cd /tmp/.fwsetup/
      cat /sysroot/boot/vendorfw/firmware.cpio | cpio -id --quiet --no-absolute-filenames
      mv vendorfw/*  /sysroot/lib/firmware
      rm -rf /tmp/.fwsetup
    '';
    requiredBy = [ "initrd-fs.target" ];
  };

  # Disable upstream firmware extraction
  hardware.asahi.extractPeripheralFirmware = false;
}