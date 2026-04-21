apk update
apk add curl git build-base ncurses-dev bison flex bc perl elfutils-dev linux-headers

curl -L -o /usr/local/bin/find  https://github.com/mlyxshi/flake/releases/download/$(uname -m)/find
chmod +x /usr/local/bin/find

git clone  https://git.busybox.net/busybox/ /root/busybox
git clone --depth=1 https://github.com/torvalds/linux /root/linux
git clone --depth=1 https://github.com/mlyxshi/flake /root/flake

mkdir /root/build
for f in init kernel.config busybox.config cloud-init-networkcfg.c udhcpc-script.sh; do
  cp "/root/flake/dd/busybox/$f" /root/build
done
gcc -s --static /root/build/cloud-init-networkcfg.c -o /root/build/cloud-init-networkcfg

cd /root/busybox
# https://bugs.busybox.net/show_bug.cgi?id=10296
git restore --source 0b1c62934215a08351a80977c7cf8e9346683a1e^  -- scripts/kconfig/conf.c
make allnoconfig KCONFIG_ALLCONFIG=/root/build/busybox.config
LDFLAGS="--static" make -j4
cp busybox /root/build

cat > /root/build/cpio.list <<EOF
dir /dev 0755 0 0
nod /dev/console 0600 0 0 c 5 1
file /init /root/build/init 0755 0 0
dir /bin 0755 0 0
file /bin/busybox /root/build/busybox 0755 0 0
file /bin/udhcpc-script.sh /root/build/udhcpc-script.sh 0755 0 0
file /bin/cloud-init-networkcfg /root/build/cloud-init-networkcfg 0755 0 0
EOF

cd /root/linux
arch=$(uname -m)
if [ "$arch" = "x86_64" ]; then
  make ARCH=x86_64 KCONFIG_ALLCONFIG=/root/build/kernel.config allnoconfig
  ./scripts/config --set-str CONFIG_INITRAMFS_SOURCE /root/build/cpio.list
  make bzImage -j4
  ln -s arch/x86/boot/bzImage /root/build/busybox-kernel
elif [ "$arch" = "aarch64" ]; then
  make ARCH=arm64 KCONFIG_ALLCONFIG=/root/build/kernel.config allnoconfig
  ./scripts/config --set-str CONFIG_INITRAMFS_SOURCE /root/build/cpio.list
  make Image -j4
  ln -s /linux/arch/arm64/boot/Image /root/build/busybox-kernel
else
  echo "Unsupported arch: $arch"
  exit 1
fi
