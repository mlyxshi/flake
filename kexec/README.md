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
curl -LO https://github.com/mlyxshi/flake/releases/download/$(uname -m)/initrd
curl -LO https://github.com/mlyxshi/flake/releases/download/$(uname -m)/kernel
curl -LO https://github.com/mlyxshi/flake/releases/download/$(uname -m)/kexec
chmod +x kexec
./kexec --debug --initrd=./initrd --load ./kernel --append=ip=dhcp
systemctl kexec -i
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
