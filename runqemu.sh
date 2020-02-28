#!/bin/sh
# version 2.0

SUDO=sudo

#QEMU=qemu-system-aarch64
QEMU=/usr/bin/qemu-system-aarch64
#QEMU=/home/akashi/bin/qemu-system-aarch64
#QEMU=/home/akashi/x86/build/qemu-system.v3/aarch64-softmmu/qemu-system-aarch64
##QEMU=/home/akashi/x86/build/qemu-system.v4/aarch64-softmmu/qemu-system-aarch64
GICV=3
#VIRT=on
VIRT=off

# no messages come out:
#QEMU=/home/akashi/x86/build/qemu-system.v3/aarch64-softmmu/qemu-system-aarch64

#ROOTDIR=/opt/buildroot/16.11_64
ROOTDIR=/opt/ubuntu/16.04
#ROOTDIR=/opt/debian/jessie
#ROOTDIR=/media/akashi/root

ROOTFSIMG=/opt/buildroot/16.11_64.ext4

#SATAIMG=/opt/disk/test_vfat.img
#SATAIMG=/opt/disk/test_vfat256M.img
SATAIMG=/opt/disk/uboot_bootdev.img
#SATAIMG=/opt/disk/heinrich-sct-arm64.img.2MB
#SATAIMG=/opt/disk/test_fat_dospart.img
#SATAIMG=/tmp/mmc-fat-part
#SATAIMG=/tmp/image-file

SATAIMG2=/opt/disk/uboot_sct.img
#SATAIMG2=/opt/disk/uboot_sct.img_bad
#SATAIMG2=/opt/disk/uboot_bootdev2.img
#SATAIMG2=/opt/disk/test_ext4.img

#MMCIMG=/opt/disk/uboot_sct.img
#MMCIMG=/opt/disk/test_vfat.img
#USBIMG=/opt/disk/ubuntu-18.04.1-server-arm64.iso
MMCIMG=/opt/disk/uboot_efi_env.img

# qemu default network
#hub 0
# \ hub0port1: user.0: index=0,type=user,net=10.0.2.0,restrict=off
# \ hub0port0: virtio-net-pci.0: index=0,type=nic,model=virtio-net-pci,macaddr=52:54:00:12:34:56
# old style (-netdev ... -device ...)
#NETWORK="-net user,id=mynet0,net=192.168.11.0/24 -net nic,model=virtio"
# new style
#NETWORK="-netdev type=user,id=mynet0,dns=10.213.17.100,net=192.168.11.0/24 -device virtio-net-device,netdev=mynet0"
# sync with /etc/my-qmeu-if[up|down]
#NETWORK="-netdev tap,id=mynet0,script=/etc/my-qemu-ifup,downscript=/etc/my-qemu-ifdown -device virtio-net-device,netdev=mynet0"

NETWORK="-netdev bridge,br=armbr0,id=hn0,helper=/home/akashi/x86/build/qemu-system/qemu-bridge-helper -device virtio-net-pci,netdev=hn0"
#NETWORK="-netdev bridge,br=armbr0,id=hn0,helper=/home/akashi/x86/build/qemu-system/qemu-bridge-helper -device e1000,netdev=hn0"


###
### UEFI specific
###

# This has a pseudo random seed service.
#UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/edk2/Build.0728/ArmVirtQemu-AARCH64/DEBUG_GCC49/FV/QEMU_EFI.fd
#UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/Build.0206/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV/QEMU_EFI.fd
UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV/QEMU_EFI.fd

# old
#UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/edk2/Build/ArmVirtQemu-AARCH64/DEBUG_GCC49/FV/QEMU_EFI.fd
#UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/edk2/Build.0619/ArmVirtQemu-AARCH64/DEBUG_GCC49/FV/QEMU_EFI.fd
### Ard's kaslr version for FVP
# UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/ard/nt-fw.bin
# UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/ard/QEMU_EFI.fd.KASLR

###
### U-boot
###
#UBOOT_PATH=/home/akashi/arm/armv8/linaro/build/uboot_201805/u-boot.bin
# please run create_flash.sh for extra env space
UBOOT_PATH=/home/akashi/tmp/uboot_64/u-boot.bin
# for ATF,
# for old build.0830
ATF_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build.0830/qemu/debug/bl1.bin64
FIP_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build.0830/qemu/debug/fip_uboot.bin64
# for secboot
#ATF_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/release/bl1.bin64
#FIP_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/release/fip_ubootsec.bin64
#FIP_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/release/fip_ubootsec1910.bin64
#FIP_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/release/fip_uboot1910.bin64
#FIP_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/release/fip_atfboot.bin64


###
### Linux loading
###
KDIR=none
IMAGE=/home/akashi/arm/armv8/linaro/build/kernel_${KDIR}/arch/arm64/boot/Image

#DTB="-dtb /home/akashi/arm/armv8/linaro/uefi/atf/fdts/fvp-base-gicv3-psci.dtb"
#DTB="-dtb /home/akashi/tmp/uboot_64/fdt_qemu3.dtb"

CMDLINE="ip=dhcp loglevel=9 consolelog=9"
#CMDLINE="ip=192.168.10.11:192.168.10.1:192.168.10.1:255.255.255.0: loglevel=9 consolelog=9"
#CMDLINE="${CMDLINE} console=ttyAMA0 earlycon=pl011,0x90000000"
#CMDLINE="${CMDLINE} console=ttyAMA1 earlycon=pl011,0x90500000"

CMDLINE="${CMDLINE} S"
#CMDLINE="${CMDLINE} init=/bin/sh"
#CMDLINE="${CMDLINE} initcall_debug"
CMDLINE="${CMDLINE} crashkernel=256M"

SWAPFILE=/home/akashi/arm/armv8/linaro/uefi/swap_512m.img

print_usage() {
	echo `basename $0` [-cdhkKlLnstuUv9] [\<kernerl_name\>]
	echo "  c: enable crash dump"
	echo "  d: turn on qemu debug"
	echo "  h: enable hibernate (w/ swap dev)"
	echo "  k: enable kgdb"
	echo "  K: enable kgdb, waiting at boot"
	echo "  l: uefi + linux boot"
	echo "  L: direct linux boot"
	echo "  n: no execute, echoing command"
	echo "  s: secure boot with atf"
	echo "  t: console in telnet mode"
	echo "  u: uboot"
	echo "  U: usb storage"
	echo "  v: virtio root filesystem"
	echo "  9: 9P root filesystem"
	exit 1
}

while getopts cdhkKlLnstuUv9 OPT
do
	case ${OPT} in
	c) cflag=1;;
	d) dflag=1;;
	h) hflag=1;;
	k) kflag=1;;
	K) Kflag=1;;
	l) lflag=1;;
	L) Lflag=1;;
	n) nflag=1;;
	s) sflag=1;;
	t) tflag=1;;
	u) uflag=1;;
	U) Uflag=1;;
	v) vflag=1;;
	9) R9flag=1;;
	*) print_usage;;
	esac
done
shift `expr ${OPTIND} - 1`

if [ $# -ne 0 ] ; then
	KDIR=$1
	IMAGE=/home/akashi/arm/armv8/linaro/build/kernel_${KDIR}/arch/arm64/boot/Image
fi

if [ x$uflag != x"" ] ; then
  if [ x$sflag != x"" ] ; then
	BOOTBIN="-drive file=${ATF_PATH},format=raw,if=pflash,index=0"
	BOOTBIN="${BOOTBIN} -drive file=${FIP_PATH},format=raw,if=pflash,index=1"
	GICV=2
#	GICV=3
	SECURE="secure=on"
  else
	BOOTBIN="-drive file=${UBOOT_PATH},format=raw,if=pflash,index=0"
#	BOOTBIN="-bios ${UBOOT_PATH}"
  fi
else
  if [ x$sflag != x"" ] ; then
FIP_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/debug/fip_edk2.bin64
	BOOTBIN="-drive file=${ATF_PATH},format=raw,if=pflash,index=0"
#	BOOTBIN="${BOOTBIN} -drive file=${FIP_PATH},format=raw,if=pflash,index=1"
	GICV=2
	SECURE="secure=on"
  else
	BOOTBIN="-bios ${UEFI_PATH}"
  fi
fi

if [ x$hflag != x"" ] ; then
	SWAPDEV="-drive file=${SWAPFILE},cache=none,if=virtio,format=raw"
fi

if [ x$tflag != x"" ] ; then
	# for telnet,
	SERIAL="-serial telnet:localhost:1234,server,nowait"
	# for nc -l,
	#SERIAL="-serial telnet:localhost:1234,nowait"
	SERIAL="${SERIAL} -serial telnet:localhost:1235,server,nowait"
fi

if [ x$vflag != x"" ] ; then
	CMDLINE="${CMDLINE} root=/dev/vda rootfstype=ext4 rw"
	VFS="-drive if=none,file=${ROOTFSIMG},id=hd0 -device virtio-blk-device,drive=hd0"
elif [ x$R9flag != x"" ] ; then
	#CMDLINE="${CMDLINE} root=baa rootfstype=9p rootflags=trans=virtio rw"
	CMDLINE="${CMDLINE} root=baa rootfstype=9p rootflags=trans=virtio,cache=loose rw"
	RFS9P="-fsdev local,id=baa,path=${ROOTDIR},security_model=none -device virtio-9p-device,fsdev=baa,mount_tag=/dev/root"
else
	CMDLINE="${CMDLINE} root=/dev/nfs nfsroot=192.168.10.1:${ROOTDIR},tcp rw"
fi

if [ x$cflag != x"" ] ; then
	#CMDLINE="${CMDLINE} crashkernel=512M-2G:64M,2G-:128M"
	#CMDLINE="${CMDLINE} crashkernel=256M mem=512M"
	CMDLINE="${CMDLINE} crashkernel=128M"
fi

if [ x$Kflag != x"" ] ; then
	CMDLINE="${CMDLINE} kgdbwait kgdboc=ttyAMA2"
elif [ x$kflag != x"" ] ; then
	CMDLINE="${CMDLINE} kgdboc=ttyAMA2"
fi

if [ x$dflag != x"" ] ; then
	DEBUG="-s -S"
	#DEBUG="-S"
	#DEBUG="-gdb tcp::5000 ${DEBUG}"
fi

if [ x$nflag != x"" ] ; then
	ECHO=echo
fi

SATADISK="-device ich9-ahci,id=ahci \
	-device ide-drive,drive=my_hd,bus=ahci.0 \
	-drive if=none,id=my_hd,format=raw,file=${SATAIMG}"
SATADISK2="-device ide-drive,drive=my_hd2,bus=ahci.1 \
	-drive if=none,id=my_hd2,format=raw,file=${SATAIMG2}"
MMCDISK=" -device sdhci-pci \
	-device sd-card,drive=my_sd \
	-drive if=none,id=my_sd,format=raw,file=${MMCIMG}"
#MMCDISK=" -device sd-card,id=sd0 \
#	-drive if=none,id=sd0,format=raw,file=${MMCIMG}"
#MMCDISK=" -drive if=none,id=sd1,format=raw,file=${MMCIMG}"
USBDISK="-device usb-ehci,id=ehci \
	-device usb-kbd,port=1 \
	-device usb-storage,drive=my_usbmass \
	-drive if=none,id=my_usbmass,format=raw,file=${USBIMG}"

DISKS=""
if [ x${SATAIMG} != x"" ] ; then
	DISKS="${DISKS} ${SATADISK}"
fi
if [ x${SATAIMG2} != x"" ] ; then
	DISKS="${DISKS} ${SATADISK2}"
fi
if [ x${MMCIMG} != x"" ] ; then
	DISKS="${DISKS} ${MMCDISK}"
fi
if [ x${Uflag} != x"" ] ; then
  if [ x${USBIMG} != x"" ] ; then
	  DISKS="${DISKS} ${USBDISK}"
  fi
fi

###
###
###

cd /home/akashi/arm/armv8/linaro/uefi
#cd /home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/debug

KERNBIN="-kernel ${IMAGE} ${DTB}"

#	-drive if=pflash,index=1,format=raw,file=/opt/buildroot/16.11_64.vfat \

CMD="${SUDO} ${QEMU} ${DEBUG} ${SERIAL} \
	-nographic \
	-machine virt,gic-version=${GICV},virtualization=${VIRT},${SECURE} \
	-cpu cortex-a57 -smp 4 \
	-m 512 \
	-semihosting \
	${NETWORK} \
	${RFS9P} \
	${VFS} \
	${DISKS} \
	${SWAPDEV}"
#	-rtc base=utc"

#	for system's old qemu,
#	-machine virt,${SECURE} \

if [ x$Lflag != x"" ] ; then
	${ECHO} ${CMD} ${KERNBIN} -append "${CMDLINE}"
elif [ x$lflag != x"" ] ; then
	${ECHO} ${CMD} ${BOOTBIN} ${KERNBIN} -append "${CMDLINE}"
else
	${ECHO} ${CMD} ${BOOTBIN} ${DTB}
fi

#	-machine virt,dumpdtb=/tmp/qemu.dtb \

#	-serial telnet:localhost:1234,server,nowait \
#	-serial pty \
#	-chardev tty,id=ptsX,path=/dev/pts/19 \
#	-device virtio-serial-device,chardev=ptsX \

#-machine virt -cpu cortex-a57 \
#-machine virt -cpu cortex-a57 -machine type=virt \
#-machine virt-2.12,gic-version=3,virtualization=on \
#	-machine virt,gic-version=${GICV},virtualization=on,${SECURE} \

# alternatives are:
#-serial stdio \
#-curses \
#-nographic \
