{ config, pkgs, lib, ... }:
let 
  kernelTarget = pkgs.hostPlatform.linux-kernel.target;
in {
  time.timeZone = "UTC";
  networking.hostName = "systemd-initrd";

  system.stateVersion = lib.trivial.release;

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    postBuild = ''
      mkdir -p $out/nix-support
      cat > $out/nix-support/hydra-build-products <<EOF
      file initrd $out/initrd
      file kernel $out/${kernelTarget}
      file kexec $out/bin/kexec
      EOF
    '';
  };
}
