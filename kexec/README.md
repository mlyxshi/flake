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

curl -LO https://github.com/mlyxshi/flake/releases/download/$(uname -m)/kexec
curl -LO https://github.com/mlyxshi/flake/releases/download/$(uname -m)/initrd
curl -LO https://github.com/mlyxshi/flake/releases/download/$(uname -m)/kernel

chmod +x ./kexec
./kexec --kexec-syscall-auto  --initrd=./initrd --load ./kernel
./kexec -e
```

# cpio
```
mkdir /test && cd test
zstdcat /run/current-system/initrd | cpio -idv 
```