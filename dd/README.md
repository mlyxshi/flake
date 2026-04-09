# Create UEFI GPT aarch64 nixos raw disk image
```
fallocate -l 3G arm-init-grow.raw
losetup -fP --show arm-init-grow.raw

sgdisk --new=0:0:+512M --typecode=0:ef00 /dev/loop1
sgdisk --new=0:0:0 --typecode=0:8305 /dev/loop1

mkfs.fat -F 32 /dev/loop1p1
mkfs.ext4 -F /dev/loop1p2
mkdir -p /mnt
mount /dev/loop1p2 /mnt
mount --mkdir /dev/loop1p1 /mnt/boot

nixos-install --flake /flake#arm-init-grow


umount /dev/loop1p1
umount /dev/loop1p2
losetup -d /dev/loop1
```




# Create LegacyBios GPT x86-64 nixos raw disk image
```
fallocate -l 3G bios-init.raw
losetup -fP --show bios-init.raw

# limine require raw partition for bios compatibility
sgdisk -n 0:0:+1M -t 0:ef02 /dev/loop1

sgdisk -n 0:0:+200M /dev/loop1
sgdisk -n 0:0:0 /dev/loop1

mkfs.fat -F 32 /dev/loop1p2
mkfs.ext4 -F /dev/loop1p3
mkdir -p /mnt
mount /dev/loop1p3 /mnt
mount --mkdir /dev/loop1p2 /mnt/boot

nixos-install --flake /flake#bios-init


umount /dev/loop1p2
umount /dev/loop1p3
losetup -d /dev/loop1
```


### Extra
nixos-install is a wrapper 
```
outPath=$(nix build --store /mnt --no-link --print-out-paths /flake#nixosConfigurations.arm-init-grow.config.system.build.toplevel)
nix-env --store /mnt -p /mnt/nix/var/nix/profiles/system --set $outPath
mkdir /mnt/etc
touch /mnt/etc/NIXOS
NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot
```