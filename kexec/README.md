# Intro
Based on [dep-sys/nix-dabei](https://github.com/dep-sys/nix-dabei/)

Modified for personal usage

Only support ext4 and vfat
```
remount-root.service  [ switch-root is required, because nix --store do not support rootfs ]
    |
    v
initrd-fs.target
    |
    v
initrd.target(default)
```
# Usage
### From running linux distro
```
curl -sL http://hydra.mlyxshi.com/job/nixos/flake/kexec-$(uname -m)/latest/download-by-type/file/kexec-script | bash -s
```
### From netboot.xyz ipxe(Rescue Oracle aarch64)

```sh
# UEFI Shell
FS0:
ifconfig -s eth0 dhcp
tftp 138.2.16.45 arm.efi
exit
```
# Test(in macOS qemu)

```
# Because most of my servers are oracle aarch64 and my main machine is mac mini m1, only test in aarch64-darwin qemu
test -f disk.img || qemu-img create -f qcow2 disk.img 10G
qemu-system-aarch64  -machine virt \
    -cpu cortex-a72 \
    -m 2048 \
    -kernel ./Image  -initrd ./initrd \
    -append "console=ttyS0 systemd.journald.forward_to_console init=/bin/init ssh_authorized_key=c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1wYVkzTHlDVzRISHFicDRTQTR0bkErMUJrZ3dydHJvMnMvREVzQmNQRGUKCg==" \
    -nographic \
    -netdev user,id=net0,hostfwd=tcp::8022-:22 -device virtio-net-pci,netdev=net0  \
    -drive file=disk.img,format=qcow2,id=mydrive   -device virtio-blk,drive=mydrive \
    -bios $(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd | head -n1)
```

# cpio
```
mkdir /test && cd test
zstdcat /run/current-system/initrd | cpio -idv 
```