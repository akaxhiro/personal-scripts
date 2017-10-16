#!/bin/sh

KERNEL=~/arm/armv7/linaro/build/kernel_v4.11/arch/arm/boot/zImage
DTB=~/arm/armv7/linaro/build/kernel_v4.11/arch/arm/boot/dts/vexpress-v2p-ca15-tc1.dtb

ROOTFS=/opt/ubuntu/16.04_32

CMDLINE="ip=dhcp noinitrd \
         loglevel=9 consolelog=9 console=ttyAMA0 earlyprintk=pl011,0x09000"
CMDLINE="${CMDLINE} S root=/dev/nfs nfsroot=192.168.10.1:${ROOTFS} rw"

#NETWORK="-net user,id=mynet0,net=192.168.11.0/24 -net nic,model=virtio"

qemu-system-arm \
-nographic \
-semihosting \
-M vexpress-a15 \
-m 256M \
-kernel ${KERNEL} \
-dtb ${DTB} \
-append "${CMDLINE}" \
${NETWORK}

#
#-serial stdio  \
#-initrd initramfs \
