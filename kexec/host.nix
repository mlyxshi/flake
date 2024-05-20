{ config, pkgs, lib, ... }: {
  # prepare /sysroot for switch-root
  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  system.stateVersion = lib.trivial.release;

  boot.kernelPatches = [
    {
      name = "zboot-compression";
      patch = null;
      extraStructuredConfig.EFI_ZBOOT = lib.kernel.yes;
    }
  ];

  system.build.kexec = pkgs.runCommand "" { } ''
    mkdir -p $out
    ln -s ${config.system.build.initialRamdisk}/initrd $out/initrd
    ln -s ${config.system.build.kernel} $out/kernel
    ln -s ${pkgs.pkgsStatic.kexec-tools}/bin/kexec $out/kexec
  '';
}
