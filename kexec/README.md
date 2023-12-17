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
tftp 138.2.16.45 netboot.xyz.efi
exit

# Test
```
nix run -L .#

# quit: [ctrl+a] then press [x]
```




# cpio
```
mkdir /test && cd test
zstdcat /run/current-system/initrd | cpio -idv 
```