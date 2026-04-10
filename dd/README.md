# Create UEFI GPT aarch64 nixos raw disk image
nix build --no-link --print-out-paths .#nixosConfigurations.arm-init.config.system.build.image



# Create LegacyBios GPT x86-64 nixos raw disk image
```
fallocate -l 3G bios-init.raw
losetup -fP --show bios-init.raw

# limine require this partition for bios compatibility under gpt
sgdisk -n 0:0:+1M -t 0:ef02 /dev/loop1

sgdisk -n 0:0:+200M /dev/loop1
sgdisk -n 0:0:0 /dev/loop1

mkfs.fat -F 32 /dev/loop1p2
mkfs.ext4 /dev/loop1p3
mkdir -p /mnt
mount /dev/loop1p3 /mnt
mount --mkdir /dev/loop1p2 /mnt/boot

outPath=$(nix build --store /mnt --no-link --print-out-paths /flake#nixosConfigurations.bios-vda-init.config.system.build.toplevel)
nix-env --store /mnt -p /mnt/nix/var/nix/profiles/system --set $outPath
mkdir /mnt/etc && touch /mnt/etc/NIXOS
NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot


nix run nixpkgs#limine bios-install /dev/loop1

umount /dev/loop1p2
umount /dev/loop1p3
losetup -d /dev/loop1
```

```
wget https://github.com/mlyxshi/flake/releases/download/$(uname -m)/busybox-kernel
cat > /boot/grub/custom.cfg <<EOF
menuentry "KernelBusyBox" --id KernelBusyBox {
  insmod ext2
  search -f /etc/hostname --set root
  linux /root/busybox-kernel
}
set default="KernelBusyBox"
EOF
reboot
```

```
wget -qO- https://dd.mlyxshi.com/arm-init.raw | dd of=/dev/sda

wget -qO- https://dd.mlyxshi.com/bios-vda-init.raw | dd of=/dev/vda

```

```
wget https://github.com/mlyxshi/flake/releases/download/$(uname -m)/busybox-kernel
wget https://github.com/mlyxshi/flake/releases/download/$(uname -m)/kexec
chmod +x kexec
./kexec --load ./busybox-kernel
systemctl kexec -i
```