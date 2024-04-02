{ pkgs, lib, config, ... }:
let
  kernelTarget = pkgs.hostPlatform.linux-kernel.target;
in {
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
