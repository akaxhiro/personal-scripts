#!/bin/sh
# version 2.0

SUDO=sudo

#QEMU=qemu-system-aarch64
QEMU=/home/akashi/bin/qemu-system-aarch64

ROOTDIR=/opt/buildroot/16.11_64
#ROOTDIR=/opt/ubuntu/16.04
#ROOTDIR=/opt/debian/jessie
#ROOTDIR=/media/akashi/root

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

#NETWORK="-netdev bridge,br=armbr0,id=hn0,helper=/home/akashi/x86/build/qemu-system/qemu-bridge-helper -device virtio-net-pci,netdev=hn0"


###
### UEFI specific
###
UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/edk2/Build/ArmVirtQemu-AARCH64/DEBUG_GCC49/FV/QEMU_EFI.fd
#UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/edk2/Build.0619/ArmVirtQemu-AARCH64/DEBUG_GCC49/FV/QEMU_EFI.fd
### Ard's kaslr version for FVP
# UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/ard/nt-fw.bin
# UEFI_PATH=/home/akashi/arm/armv8/linaro/uefi/ard/QEMU_EFI.fd.KASLR

BOOTBIN="-bios ${UEFI_PATH}"
# BOOTBIN="-pflash flash_uefi.img -pflash flash_var.img"


###
### Linux loading
###
KDIR=none
IMAGE=../build/kernel_${KDIR}/arch/arm64/boot/Image

#DTB="-dtb /home/akashi/arm/armv8/linaro/uefi/atf/fdts/fvp-base-gicv3-psci.dtb"

CMDLINE="ip=dhcp loglevel=9 consolelog=9"
#CMDLINE="${CMDLINE} console=ttyAMA0 earlycon=pl011,0x90000000"
#CMDLINE="${CMDLINE} console=ttyAMA1 earlycon=pl011,0x90500000"

#CMDLINE="${CMDLINE} S"
#CMDLINE="${CMDLINE} init=/bin/sh"

SWAPFILE=/home/akashi/arm/armv8/linaro/uefi/swap_512m.img

print_usage() {
	echo `basename $0` [-cdhkKlLnt9] [\<kernerl_name\>]
	echo "  c: enable crash dump"
	echo "  d: turn on qemu debug"
	echo "  h: enable hibernate (w/ swap dev)"
	echo "  k: enable kgdb"
	echo "  K: enable kgdb, waiting at boot"
	echo "  l: uefi + linux boot"
	echo "  L: direct linux boot"
	echo "  n: no execute, echoing command"
	echo "  t: console in telnet mode"
	echo "  9: 9P root filesystem"
	exit 1
}

while getopts cdhkKlLnt9 OPT
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
	t) tflag=1;;
	9) R9flag=1;;
	*) print_usage;;
	esac
done
shift `expr ${OPTIND} - 1`

if [ $# -ne 0 ] ; then
	KDIR=$1
	IMAGE=/home/akashi/arm/armv8/linaro/build/kernel_${KDIR}/arch/arm64/boot/Image
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

if [ x$R9flag != x"" ] ; then
	#CMDLINE="${CMDLINE} root=baa rootfstype=9p rootflags=trans=virtio rw"
	CMDLINE="${CMDLINE} root=baa rootfstype=9p rootflags=trans=virtio,cache=loose rw"
	RFS9P="-fsdev local,id=baa,path=${ROOTDIR},security_model=none -device virtio-9p-device,fsdev=baa,mount_tag=/dev/root"
else
	CMDLINE="${CMDLINE} root=/dev/nfs nfsroot=192.168.10.1:${ROOTDIR},tcp rw"
fi

if [ x$cflag != x"" ] ; then
	#CMDLINE="${CMDLINE} crashkernel=512M-2G:64M,2G-:128M"
	CMDLINE="${CMDLINE} crashkernel=256M mem=512M"
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

###
###
###

cd /home/akashi/arm/armv8/linaro/uefi

KERNBIN="-kernel ${IMAGE} ${DTB}"

CMD="${SUDO} ${QEMU} ${DEBUG} \
	-nographic ${SERIAL} \
	-machine virt,gic-version=3,virtualization=on \
	-cpu cortex-a57 -smp 2 \
	-m 1024 \
	-semihosting \
	${NETWORK} \
	${RFS9P} \
	${SWAPDEV}"

if [ x$Lflag != x"" ] ; then
	${ECHO} ${CMD} ${KERNBIN} -append "${CMDLINE}"
elif [ x$lflag != x"" ] ; then
	${ECHO} ${CMD} ${BOOTBIN} ${KERNBIN} -append "${CMDLINE}"
else
	${ECHO} ${CMD} ${BOOTBIN}
fi

#	-machine virt,dumpdtb=/tmp/qemu.dtb \

#	-serial telnet:localhost:1234,server,nowait \
#	-serial pty \
#	-chardev tty,id=ptsX,path=/dev/pts/19 \
#	-device virtio-serial-device,chardev=ptsX \

#-machine virt -cpu cortex-a57 \
#-machine virt -cpu cortex-a57 -machine type=virt \

# alternatives are:
#-serial stdio \
#-curses \
