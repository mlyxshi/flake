{ pkgs, lib, config, ... }:
let
  kernelTarget = pkgs.hostPlatform.linux-kernel.target;
  arch = pkgs.hostPlatform.uname.processor;

  kexecScript = pkgs.writeTextDir "script/kexec-script" ''
    #!/usr/bin/env bash
    set -e   
    echo "Downloading ${arch} kexec-musl-bin" && curl -LO http://hydra.mlyxshi.com/job/nixos/flake/kexec-${arch}/latest/download-by-type/file/kexec && chmod +x ./kexec
    echo "Downloading ${arch} initrd" && curl -LO http://hydra.mlyxshi.com/job/nixos/flake/kexec-${arch}/latest/download-by-type/file/initrd
    echo "Downloading ${arch} kernel" && curl -LO http://hydra.mlyxshi.com/job/nixos/flake/kexec-${arch}/latest/download-by-type/file/kernel

    echo "Wait ssh connection lost..., ssh root@ip and enjoy NixOS"
    ./kexec --kexec-syscall-auto --load ./kernel --initrd=./initrd  --append "init=/bin/init ${toString config.boot.kernelParams} $*"
    ./kexec -e
  '';
in {
  system.build.kexec = pkgs.symlinkJoin {
    name = "kexec";
    paths = [
      config.system.build.kernel
      config.system.build.initialRamdisk
      kexecScript
      pkgs.pkgsStatic.kexec-tools
    ];
    postBuild = ''
      mkdir -p $out/nix-support
      cat > $out/nix-support/hydra-build-products <<EOF
      file initrd $out/initrd
      file kernel $out/${kernelTarget}
      file kexec-script $out/script/kexec-script
      file kexec $out/bin/kexec
      EOF
    '';
  };
}
