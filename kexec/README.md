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
### From running linux distro(aarch64)
```
curl -LO http://hydra.mlyxshi.com/job/nixos/flake/kexec-$(uname -m)/latest/download-by-type/file/kexec 
curl -LO http://hydra.mlyxshi.com/job/nixos/flake/kexec-$(uname -m)/latest/download-by-type/file/initrd
curl -LO http://hydra.mlyxshi.com/job/nixos/flake/kexec-$(uname -m)/latest/download-by-type/file/kernel

chmod +x ./kexec
./kexec --kexec-syscall-auto --load ./kernel --initrd=./initrd
./kexec -e
```

# cpio
```
mkdir /test && cd test
zstdcat /run/current-system/initrd | cpio -idv 
```