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
    };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";


  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.timeout = 1;

  hardware.asahi.extractPeripheralFirmware = false;

  # cat /boot/vendorfw/firmware.cpio | cpio -id --quiet --no-absolute-filenames
  # so it is friendly(pure) for flake users
  hardware.firmware = [
      (pkgs.stdenv.mkDerivation {
        name = "asahi-peripheral-firmware";
        buildCommand = ''
          mkdir -p $out/lib/firmware/
          cp -r ${./firmware}/* $out/lib/firmware/
        '';
      })
    ];
    
}
