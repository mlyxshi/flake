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

ip=dhcp
```

# Usage
### From running linux distro
```
curl -LO https://github.com/mlyxshi/flake/releases/download/$(uname -m)/initrd
curl -LO https://github.com/mlyxshi/flake/releases/download/$(uname -m)/kernel
curl -LO https://github.com/mlyxshi/flake/releases/download/$(uname -m)/kexec
chmod +x kexec
encoded_key=$(echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" | base64 -w0)
./kexec --initrd=./initrd --load ./kernel --append="root=fstab systemd.set_credential_binary=ssh.authorized_keys.root:$encoded_key"
systemctl kexec -i
```

# Test from VNC
## Useful for 512MB memory vps
kexec preserves some RAM; Reboot resets it.

kexec cost ~280 MB memory while Reboot cost ~80 MB.
```
wget https://github.com/mlyxshi/flake/releases/download/x86_64/initrd
wget https://github.com/mlyxshi/flake/releases/download/x86_64/kernel
encoded_key=$(echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpaY3LyCW4HHqbp4SA4tnA+1Bkgwrtro2s/DEsBcPDe" | base64 -w0)

cat > /boot/grub/custom.cfg <<EOF
menuentry "NixOS" --id NixOS {
  insmod ext2
  search -f /etc/hostname --set root
  linux /root/kernel systemd.journald.forward_to_console root=fstab systemd.set_credential_binary=ssh.authorized_keys.root:$encoded_key
  initrd /root/initrd
}
set default="NixOS"
EOF
```

# cpio
```
mkdir /test 
cd test
zstdcat /run/current-system/initrd | cpio -idv 
```
