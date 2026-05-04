# Install

qemu-img create -f raw alpine-riscv64.raw 50G

qemu-system-riscv64 -machine virt,acpi=off  -smp 8 -m 2G \
    -nographic \
    -drive if=pflash,format=raw,unit=0,file=/Users/dominic/vfkit/edk2-riscv-code.fd,readonly=on \
    -drive if=pflash,format=raw,unit=1,file=/Users/dominic/vfkit/edk2-riscv-vars.fd \
    -device virtio-rng-device \
    -netdev user,hostfwd=tcp:127.0.0.1:2222-:22,id=n0 \
    -device virtio-net-device,netdev=n0 \
    -drive file=alpine-standard-3.23.4-riscv64.iso,media=cdrom,if=none,id=cd0,readonly=on \
    -device virtio-blk-device,drive=cd0 \
    -drive file=alpine-riscv64.raw,if=none,id=hd0 \
    -device virtio-blk-device,drive=hd0 
    

#  Usage 


qemu-system-riscv64 -machine virt,acpi=off  -smp 8 -m 2G \
    -nographic \
    -drive if=pflash,format=raw,unit=0,file=/Users/dominic/vfkit/edk2-riscv-code.fd,readonly=on \
    -drive if=pflash,format=raw,unit=1,file=/Users/dominic/vfkit/edk2-riscv-vars.fd \
    -device virtio-rng-device \
    -netdev user,hostfwd=tcp:127.0.0.1:9022-:22,id=n0 \
    -device virtio-net-device,netdev=n0 \
    -drive file=alpine-riscv64.raw,if=none,id=hd0 \
    -device virtio-blk-device,drive=hd0 
    

apk update
apk add curl git build-base htop helix gdb yazi mandoc man-pages  linux-headers
