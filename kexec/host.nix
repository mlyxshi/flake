{ config, pkgs, lib, ... }:
let kernelTarget = pkgs.hostPlatform.linux-kernel.target;
in {
  networking.hostName = "systemd-initrd";

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  fonts.fontconfig.enable = false;

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  system.build.kexec = pkgs.symlinkJoin {
    name = "kexec";
    paths = [
      config.system.build.kernel
      config.system.build.initialRamdisk
      pkgs.pkgsStatic.kexec-tools
    ];
  };
}
