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

  system.build.qemu-test = pkgs.writeShellScriptBin "qemu-test" ''
    ${pkgs.qemu_kvm}/bin/qemu-system-aarch64 -machine virt -cpu host -nographic -m 8096 \
      -kernel ${config.system.build.kernel}/${pkgs.hostPlatform.linux-kernel.target}  -initrd ${config.system.build.initialRamdisk}/initrd  \
      -append "systemd.journald.forward_to_console github-private-key=''$(cat /secret/ssh/github)" \
      -device "virtio-net-pci,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::8022-:22" \
      -drive "file=disk.img,format=qcow2,if=virtio"  \
      -bios  ${pkgs.qemu_kvm}/share/qemu/edk2-aarch64-code.fd
  '';
}
