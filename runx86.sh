#!/bin/sh

SUDO="sudo -E"
#QEMU=qemu-system-x86_64
QEMU=/home/akashi/bin/qemu-system-x86_64
QEMU=/home/akashi/x86/build/qemu-system/x86_64-softmmu/qemu-system-x86_64

#CPU=host
CPU=kvm64
CPU=host
#CPU=kvm32

#UEFIFILE="/home/akashi/x86/qemu_work/OVMF.fd"
#UEFIFILE="/home/akashi/x86/build/ovmf/Build/OvmfX64/DEBUG_GCC5/FV/OVMF.fd"

UEFIFILE="/home/akashi/x86/build/ovmf/Build/OvmfX64/DEBUG_GCC5/FV/OVMF_CODE.fd"
# need to make a copy
UEFIFILE_VAR="/home/akashi/x86/OVMF_VARS.fd"
#UEFIFILE_VAR="/home/akashi/x86/ovmf_var.img"

#UBOOT_PATH=/home/akashi/x86/build/uboot_201805_rob/u-boot.bin
#run create_flash.sh at ~/x86/build
#UBOOT_PATH=/home/akashi/x86/build/u-boot.rom

#BUILD_ROM=y make O=...
#UBOOT_PATH=/home/akashi/x86/build/uboot_sct/u-boot.rom
#UBOOT_PATH=/home/akashi/x86/build/uboot_sct_32/u-boot.rom
#UBOOT_PATH=/home/akashi/x86/build/uboot_efi/u-boot.rom
UBOOT_PATH=/home/akashi/x86/build/uboot_qemu/u-boot.rom

# default
KERNFILE="/home/akashi/x86/build/kernel_416/arch/x86/boot/bzImage"

#ROOTDIR="/opt/buildroot/16.11_x86"
ROOTDIR="/opt/buildroot/16.11_x86_64"
ROOTFILE="/home/akashi/x86/build/br-16.11_64/images/rootfs.ext2"

SATAIMG=/opt/disk/uboot_sct_x86.img
MMCIMG=/opt/disk/uboot_sct_x86.img

CMDLINE="debug earlyprintk=ttyS0 vga=normal"
CMDLINE="${CMDLINE} ip=dhcp"
CMDLINE="${CMDLINE} crashkernel=256M"
CMDLINE="${CMDLINE} console=ttyS0"
#CMDLINE="${CMDLINE} efi=debug"
#CMDLINE="${CMDLINE} memblock=debug"

#NETWORK="-net user,id=mynet0,net=192.168.10.0/24 -net nic,model=virtio"
#NETWORK="-net nic,netdev=guest0 -netdev tap,id=guest0,ifname=tap0"
# temporarily for qemu 2.9
#NETWORK="-netdev bridge,br=armbr0,id=hn0 -device virtio-net-pci,netdev=hn0"
NETWORK="-netdev bridge,br=armbr0,id=hn0,helper=/home/akashi/x86/build/qemu-system/qemu-bridge-helper -device virtio-net-pci,netdev=hn0"

print_usage() {
	echo `basename $0` [-dglLnuU9]
	echo "  d: gdb debug"
	echo "  g: graphic"
	echo "  l: kernel boot with UEFI"
	echo "  L: kernel boot without UEFI"
	echo "  n: no execute, echoing command"
	echo "  u: u-boot"
	echo "  U: soly UEFI"
	echo "  9: 9P filesystem"
	exit 1
}

while getopts 9dglLnuU OPT
do
	case ${OPT} in
	d) dflag=1;;
	g) gflag=1;;
	l) lflag=1;;
	L) Lflag=1;;
	n) nflag=1;;
	u) uflag=1;;
	U) Uflag=1;;
	9) Pflag=1;;
	*) print_usage;;
	esac
done
shift `expr ${OPTIND} - 1`

if [ $# -ne 0 ] ; then
echo "ARG1 " "$1"
KERNFILE="/home/akashi/x86/build/kernel_$1/arch/x86/boot/bzImage"
echo "KERN " ${KERNFILE}
fi
KERNEL="-kernel ${KERNFILE}"

if [ x$Pflag != x"" ] ; then
	ROOTDEV="-fsdev local,id=baa,path=${ROOTDIR},security_model=none \
		 -device virtio-9p-pci,fsdev=baa,mount_tag=/dev/root"
	CMDLINE="${CMDLINE} root=baa rootfstype=9p rootflags=trans=virtio rw"
else
#	ROOTDEV="-drive file=${ROOTFILE},format=raw,if=ide"
#	CMDLINE="${CMDLINE} root=/dev/sda rw"
	CMDLINE="${CMDLINE} root=/dev/nfs nfsroot=192.168.10.1:${ROOTDIR} rw"
fi

if [ x$uflag != x"" ] ; then
#	FIRM="-pflash ${UBOOT_PATH}"
	FIRM="-bios ${UBOOT_PATH}"
else if [ x$Lflag == x"" ] ; then
#	FIRM="-pflash ${UEFIFILE}"
	FIRM="-bios ${UEFIFILE}"
#	FIRM="-drive if=pflash,format=raw,readonly,file=${UEFIFILE}"
#	FIRM="${FILE} -drive if=pflash,format=raw,file=${UEFIFILE_VAR}"
	FIRM="-drive if=pflash,format=raw,file=${UEFIFILE_VAR}"
	FIRM="${FILE} -drive if=pflash,format=raw,readonly,file=${UEFIFILE}"
fi
fi

if [ x$gflag != x"" ] ; then
	PARAMS=
else
	PARAMS=-nographic
fi

if [ x$dflag != x"" ] ; then
	DEBUG="-s -S"
fi

if [ x$nflag != x"" ] ; then
	ECHO=echo
fi

#DISKS="-device ide-hd,drive=disk,if=none \
#	-drive file=${SATAIMG},id=disk,format=raw"

DISKS=" -device ich9-ahci,id=ahci \
	-device ide-drive,drive=my_hd,bus=ahci.0 \
	-drive if=none,id=my_hd,format=raw,file=${SATAIMG}"

#DISKS="	-device sdhci-pci \
#	-device sd-card,drive=my_sd \
#	-drive if=none,id=my_sd,format=raw,file=${MMCIMG}"

NETDEV=" -net none \
	-device e1000,netdev=net0 \
	-netdev user,id=net0"

###
###
###

CMD="${SUDO} ${QEMU} ${DEBUG} -enable-kvm \
	-nographic \
	-M pc \
	-smp cpus=2 -cpu ${CPU} -m 1024M \
	${PARAMS} \
	${FIRM} \
	${ROOTDEV} \
	${DISKS} \
	${NETWORK} \
	${NETDEV} \
	-rtc base=utc"

# qemu uses i440fx
#	-M q35 \

#-curses \
# for serial and graphic consoles
#-serial stdio \

#-rtc base=localtime

if [ x$lflag != x"" ] || [ x$Lflag != x"" ] ; then
	${ECHO} ${CMD} ${KERNEL} -append "${CMDLINE}"
else
	${ECHO} ${CMD}
fi

#echo DONE
