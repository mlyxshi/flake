ncurses-terminfo-base
helix
yazi


apk update
apk add git build-base ncurses-dev bison flex bc perl elfutils


git clone --depth=1 https://github.com/mlyxshi/flake 
git clone --depth=1 https://git.busybox.net/busybox/
git clone --depth=1 https://github.com/torvalds/linux

cd /busybox
make allnoconfig
cp /flake/dd/busybox/busybox-config.sh /flake/dd/busybox/busybox.config .
source busybox-config.sh




cat > /root/profile <<EOF
alias r=yazi
export EDITOR=hx
EOF


apk add git build-base ncurses-dev bison flex bc perl elfutils

cat > /root/build/kernel.config <<EOF
# x86_64
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y

# aarch64
CONFIG_SERIAL_AMBA_PL011=y
CONFIG_SERIAL_AMBA_PL011_CONSOLE=y

CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE="/root/build/cpio.list"

CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_ELF=y

CONFIG_DEVTMPFS=y

CONFIG_PCI=y
CONFIG_PCI_HOST_GENERIC=y
CONFIG_VIRTIO_MENU=y
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_MMIO=y

CONFIG_NET=y
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
CONFIG_VIRTIO_NET=y

CONFIG_INET=y
CONFIG_UNIX=y
CONFIG_PACKET=y

CONFIG_BLK_DEV=y
CONFIG_VIRTIO_BLK=y

CONFIG_SCSI=y
CONFIG_BLK_DEV_SD=y
CONFIG_BLK_DEV_SR=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_SCSI_VIRTIO=y

CONFIG_ATA=y
CONFIG_SATA_AHCI=y

CONFIG_ISO9660_FS=y

CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_VIRTIO=y

CONFIG_EFI=y
CONFIG_ACPI=y
EOF


cat > /root/build/cpio.list <<EOF
dir /dev 0755 0 0
nod /dev/console 0600 0 0 c 5 1

file /init /root/build/init 0755 0 0
dir /bin 0755 0 0
file /bin/busybox /root/build/busybox/busybox 0755 0 0
file /bin/udhcpc-script.sh /root/build/udhcpc-script.sh 0755 0 0
file /bin/cloud-init-networkcfg /root/build/cloud-init-networkcfg 0755 0 0
EOF






apk add linux-headers
LDFLAGS="--static" make -j8
