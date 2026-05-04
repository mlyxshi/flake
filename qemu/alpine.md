# arm64-vfkit
/opt/homebrew/bin/vfkit --cpus 8 --memory 8192 --bootloader efi,variable-store=/Users/dominic/vfkit/efi-variable-store,create --device virtio-blk,path=/Users/dominic/vfkit/alpine.raw  --device virtio-serial,stdio --device virtio-net,nat,mac=72:20:43:d4:39:63


# for mdns
apk add avahi
rc-update add avahi-daemon default
rc-service avahi-daemon start


# repo

vi  /etc/apt/repositories 

# for vscode remote
vi /etc/ssh/sshd_config

change AllowTcpForwarding to yes


# only for vfkit
Use utm boot up

vi /boot/grub/grub.cfg
add console=hvc0

vi /etc/inittab
change ttyAMA0 to hvc0