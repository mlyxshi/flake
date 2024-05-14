{ config, pkgs, lib, ... }:
let kernelTarget = pkgs.hostPlatform.linux-kernel.target;
in {
  # prepare /sysroot for switch-root
  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
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
