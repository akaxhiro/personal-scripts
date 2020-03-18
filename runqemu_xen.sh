#!/bin/sh
# https://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/qemu-system-aarch64

#QEMU=/usr/bin/qemu-system-aarch64
QEMU=~/x86/build/qemu-system.v4/aarch64-softmmu/qemu-system-aarch64
#KERN=~/arm/armv8/linaro/build/kernel_v56/arch/arm64/boot/Image.gz
HD0=~/tmp/xen_work/xenial-server-cloudimg-arm64-uefi1.img
EFI=~/tmp/xen_work/QEMU_EFI.fd
#EFI=~/tmp/xen_work/XEN_EFI.fd

NETWORK="-netdev bridge,br=armbr0,id=hn0,helper=/home/akashi/x86/build/qemu-system.v4/qemu-bridge-helper -device virtio-net-pci,netdev=hn0"
#NETWORK="-netdev bridge,br=armbr0,id=hn0,helper=/home/akashi/x86/build/qemu-system.v4/qemu-bridge-helper -device e1000,netdev=hn0"
#NETWORK="-netdev user,id=hostnet0,hostfwd=tcp::2222-:22 -device virtio-net-device,netdev=hostnet0,mac=52:54:00:12:34:56"

${QEMU} \
   -machine virt,gic-version=3,virtualization=on,secure=off \
   -cpu cortex-a57 -smp 1 -m 1024 -display none \
   -serial mon:stdio \
   -d unimp \
   -bios ${EFI} \
   ${NETWORK} \
   -drive if=none,file=${HD0},id=hd0 \
   -device virtio-blk-device,drive=hd0 \
   -boot order=d
