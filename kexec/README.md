# Intro
Based on [dep-sys/nix-dabei](https://github.com/dep-sys/nix-dabei/)

Modified for personal usage

Only support ext4 and vfat

Kernel command line
```
# forward journald log to qemu console
systemd.journald.forward_to_console 
# pass priavte ssh key
systemd.set_credential_binary=github-private-key:BASE64
# inirtd hostname
systemd.hostname=systemd-initrd
# DEV： tmpfs  
# LOC：    /sysroot
# FSTYPE： tmpfs
# OPTIONS： mode=0755
systemd.mount-extra=tmpfs:/:tmpfs:mode=0755"
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