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

  hardware.asahi.extractPeripheralFirmware = false;

  # copy firmware from nixos-apple-silicon installer
  # so it is friendly for flake users
  hardware.firmware = [
      (pkgs.stdenv.mkDerivation {
        name = "asahi-peripheral-firmware";
        buildCommand = ''
          mkdir -p $out/lib/firmware/apple
          cp ${./firmware}/* $out/lib/firmware/apple
        '';
      })
    ];
    
}
