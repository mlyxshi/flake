# Intro
Only support ext4 and vfat

Kernel command line
```
# forward journald log to qemu console
systemd.journald.forward_to_console 
# pass private ssh key
systemd.set_credential_binary=github-private-key:BASE64
# initrd hostname
systemd.hostname=systemd-initrd
# DEV： tmpfs  
# DIR：    /sysroot
# FSTYPE： tmpfs
# OPTIONS： mode=0755
systemd.mount-extra=tmpfs:/:tmpfs:mode=0755"
# https://github.com/poettering/systemd/blob/9b436342705ece5304b3f6cbefd739f6da0ae742/test/test-network-generator-conversion.sh#L113
ip=dhcp
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

# tftp server all udp port 
# tftp client all port 
# UEFI Shell
```
FS0:
ifconfig -s eth0 dhcp
tftp 138.3.223.82 arm.efi
exit
```



# Server located in CN
```
curl -LO https://cdn.mlyxshi.com/x86_64/kexec
curl -LO https://cdn.mlyxshi.com/x86_64/initrd
curl -LO https://cdn.mlyxshi.com/x86_64/kernel

chmod +x ./kexec
./kexec --kexec-syscall-auto  --initrd=./initrd --load ./kernel
./kexec -e
```