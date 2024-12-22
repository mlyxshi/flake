{ config, pkgs, lib, ... }: {

  system.stateVersion = lib.trivial.release;

  system.build.kexec = pkgs.runCommand "" { } ''
    mkdir -p $out
    ln -s ${config.system.build.initialRamdisk}/initrd $out/initrd
    ln -s ${config.system.build.kernel}/${pkgs.hostPlatform.linux-kernel.target} $out/kernel
    ln -s ${pkgs.pkgsStatic.kexec-tools}/bin/kexec $out/kexec
  '';
}
