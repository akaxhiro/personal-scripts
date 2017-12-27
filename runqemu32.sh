#!/bin/sh

KERNEL=~/arm/armv7/build/kernel_414/arch/arm/boot/zImage
KERNEL=~/arm/armv7/build/kernel_415/arch/arm/boot/zImage
#KERNEL=~/arm/armv7/build/uboot_1711/u-boot.bin
DTB=~/arm/armv7/build/kernel_414/arch/arm/boot/dts/vexpress-v2p-ca15-tc1.dtb

ROOTFS=/opt/ubuntu/16.04_32
ROOTFS=/opt/buildroot/16.11_32

CMDLINE="ip=dhcp noinitrd \
         loglevel=9 consolelog=9 console=ttyAMA0 earlyprintk=pl011,0x09000"
CMDLINE="${CMDLINE} S root=/dev/nfs nfsroot=192.168.10.1:${ROOTFS} rw"

#NETWORK="-net user,id=mynet0,net=192.168.11.0/24 -net nic,model=virtio"

qemu-system-arm \
-serial stdio  \
-semihosting \
-serial telnet:localhost:1234,server,nowait \
-serial telnet:localhost:1235,server,nowait \
-M vexpress-a15 \
-kernel ${KERNEL} \
-dtb ${DTB} \
-append "${CMDLINE}" \
-m 256M \
${NETWORK}

#-M virt \
#-bios ${KERNEL} \
#
#-nographic \
#-serial stdio  \
#-initrd initramfs \
