# personal usage
{ pkgs, lib, config, ... }:
let
  kernelTarget = pkgs.hostPlatform.linux-kernel.target;
  arch = pkgs.hostPlatform.uname.processor;

  kexecScript = pkgs.writeTextDir "script/kexec-script" ''
    #!/usr/bin/env bash
    set -e   
    echo "Downloading ${arch} kexec-musl-bin" && curl -LO http://hydra.mlyxshi.com/job/kexec/build/${arch}/latest/download-by-type/file/kexec-bin && chmod +x ./kexec-bin
    echo "Downloading ${arch} initrd" && curl -LO http://hydra.mlyxshi.com/job/kexec/build/${arch}/latest/download-by-type/file/initrd
    echo "Downloading ${arch} kernel" && curl -LO http://hydra.mlyxshi.com/job/kexec/build/${arch}/latest/download-by-type/file/kernel

    for i in /etc/ssh/ssh_host_ed25519_key /persist/etc/ssh/ssh_host_ed25519_key; do
      if [[ -e $i && -s $i ]]; then 
        echo "Get ssh_host_ed25519_key  from: $i"
        ssh_host_key=$(cat $i | base64 -w0)
        break
      fi     
    done
    
    for i in /home/$SUDO_USER/.ssh/authorized_keys /root/.ssh/authorized_keys /etc/ssh/authorized_keys.d/root; do
      if [[ -e $i && -s $i ]]; then 
        echo "Get authorized_keys       from: $i"
        ssh_authorized_key=$(cat $i | base64 -w0)
        break
      fi     
    done
    
    echo "Wait ssh connection lost..., ssh root@ip and enjoy NixOS"
    ./kexec-bin --kexec-syscall-auto --load ./kernel --initrd=./initrd  --append "init=/bin/init ${toString config.boot.kernelParams} ssh_host_key=$ssh_host_key ssh_authorized_key=$ssh_authorized_key $*"
    ./kexec-bin -e
  '';

  ipxeScript = pkgs.writeTextDir "script/ipxe-script" ''
    #!ipxe
    kernel http://hydra.mlyxshi.com/job/kexec/build/${arch}/latest/download-by-type/file/kernel initrd=initrd init=/bin/init ${toString config.boot.kernelParams} ''${cmdline}
    initrd http://hydra.mlyxshi.com/job/kexec/build/${arch}/latest/download-by-type/file/initrd
    boot
  '';
in
{
  system.build.kexec = pkgs.symlinkJoin {
    name = "kexec";
    paths = [
      config.system.build.kernel
      config.system.build.initialRamdisk
      kexecScript
      ipxeScript
      pkgs.pkgsStatic.kexec-tools
    ];
    postBuild = ''
      mkdir -p $out/nix-support
      cat > $out/nix-support/hydra-build-products <<EOF
      file initrd $out/initrd
      file kernel $out/${kernelTarget}
      file kexec $out/script/kexec-script
      file ipxe $out/script/ipxe-script
      file kexec-bin $out/bin/kexec
      EOF
    '';
  };

  system.build.test = pkgs.writeShellScriptBin "test-vm" ''
    test -f disk.img || ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 disk.img 10G
    host=qemu-test-x64
    local_test=1
    exec ${pkgs.qemu_kvm}/bin/qemu-kvm -name ${config.networking.hostName} \
      -m 2048 \
      -kernel ${config.system.build.kernel}/${kernelTarget}  -initrd ${config.system.build.initialRamdisk}/initrd.zst  \
      -append "console=ttyS0 init=/bin/init ${toString config.boot.kernelParams} host=$host local_test=$local_test" \
      -no-reboot -nographic \
      -net nic,model=virtio \
      -net user,net=10.0.2.0/24,host=10.0.2.2,dns=10.0.2.3,hostfwd=tcp::2222-:22 \
      -drive file=disk.img,format=qcow2,if=virtio \
      -device virtio-rng-pci \
      -bios ${pkgs.OVMF.fd}/FV/OVMF.fd 
  '';

  # Fast Test without Install 
  system.build.test0 = pkgs.writeShellScriptBin "test-vm" ''
    test -f disk.img || ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 disk.img 10G
    exec ${pkgs.qemu_kvm}/bin/qemu-kvm -name ${config.networking.hostName} \
      -m 2048 \
      -kernel ${config.system.build.kernel}/${kernelTarget}  -initrd ${config.system.build.initialRamdisk}/initrd.zst  \
      -append "console=ttyS0 init=/bin/init ${toString config.boot.kernelParams}" \
      -no-reboot -nographic \
      -net nic,model=virtio \
      -net user,net=10.0.2.0/24,host=10.0.2.2,dns=10.0.2.3,hostfwd=tcp::2222-:22 \
      -drive file=disk.img,format=qcow2,if=virtio \
      -device virtio-rng-pci \
      -bios ${pkgs.OVMF.fd}/FV/OVMF.fd 
  '';
}
