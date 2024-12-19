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
      name = "config-zboot-zstd";
      patch = null;
      extraStructuredConfig = {
        EFI_ZBOOT = lib.kernel.yes;
        KERNEL_ZSTD = lib.kernel.yes;
      };
    }

    # https://nixos.wiki/wiki/Linux_kernel#Too_high_ram_usage
    {
      name = "disable-bpf";
      patch = null;
      extraStructuredConfig = {
        DEBUG_INFO_BTF = lib.mkForce lib.kernel.no;
      };
    }
  ];
}
