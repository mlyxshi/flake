apk update
apk add git build-base ncurses-dev bison flex bc perl elfutils linux linux-headers

git clone --depth=1 https://github.com/mlyxshi/flake 
git clone --depth=1 https://git.busybox.net/busybox/
git clone --depth=1 https://github.com/torvalds/linux

mkdir /build
for f in init kernel.config cloud-init-networkcfg.c udhcpc-script.sh; do
  cp "/flake/dd/busybox/$f" /build
done
gcc -s --static /build/cloud-init-networkcfg.c -o /build/cloud-init-networkcfg

cd /busybox
make allnoconfig
cp /flake/dd/busybox/busybox-config.sh /flake/dd/busybox/busybox.config .
source busybox-config.sh
LDFLAGS="--static" make -j4
cp busybox /build

cat > /build/cpio.list <<EOF
dir /dev 0755 0 0
nod /dev/console 0600 0 0 c 5 1
file /init /build/init 0755 0 0
dir /bin 0755 0 0
file /bin/busybox /build/busybox 0755 0 0
file /bin/udhcpc-script.sh /build/udhcpc-script.sh 0755 0 0
file /bin/cloud-init-networkcfg /build/cloud-init-networkcfg 0755 0 0
EOF

cd /linux
echo 'CONFIG_INITRAMFS_SOURCE="/build/cpio.list"' >> /build/kernel.config
arch=$(uname -m)
if [ "$arch" = "x86_64" ]; then
  make ARCH=x86_64 KCONFIG_ALLCONFIG=/build/kernel.config allnoconfig
  make bzImage -j4
  ln -s arch/x86/boot/bzImage /build/busybox-kernel
elif [ "$arch" = "aarch64" ]; then
  make ARCH=arm64 KCONFIG_ALLCONFIG=/build/kernel.config allnoconfig
  make Image -j4
  ln -s /linux/arch/arm64/boot/Image /build/busybox-kernel
else
  echo "Unsupported arch: $arch"
  exit 1
fi
