wget https://github.com/mlyxshi/flake/releases/download/$(uname -m)/busybox-kernel
wget https://github.com/mlyxshi/flake/releases/download/$(uname -m)/busybox-initrd

cat > /boot/grub/custom.cfg <<EOF
menuentry "KernelBusyBox" --id KernelBusyBox {
  insmod ext2
  search -f /etc/hostname --set root
  linux /root/busybox-kernel
  initrd /root/busybox-initrd
}
set default="KernelBusyBox"
EOF
reboot