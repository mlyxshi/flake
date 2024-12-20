{ config, pkgs, lib, ... }: {
  # prepare /sysroot for switch-root
  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  system.stateVersion = lib.trivial.release;

  system.build.kexec = pkgs.runCommand "" { } ''
    mkdir -p $out
    ln -s ${config.system.build.initialRamdisk}/initrd $out/initrd
    ln -s ${config.system.build.kernel}/${pkgs.hostPlatform.linux-kernel.target} $out/kernel
    ln -s ${pkgs.pkgsStatic.kexec-tools}/bin/kexec $out/kexec
  '';

  boot.kernelPatches = [
    {
      name = "qemu-only";
      patch = null;
      extraStructuredConfig = with lib.kernel;{
        MODULES = lib.mkForce no;
      };
    }
  ];
}
