#!/bin/sh

SUDO="sudo -E"
QEMU=/home/akashi/bin/qemu-system-x86_64

#CPU=host
CPU=kvm64

#UEFIFILE="/home/akashi/x86/qemu_work/OVMF.fd"
#UEFIFILE="/home/akashi/x86/build/ovmf/Build/OvmfX64/DEBUG_GCC5/FV/OVMF.fd"

UEFIFILE="/home/akashi/x86/build/ovmf/Build/OvmfX64/DEBUG_GCC5/FV/OVMF_CODE.fd"
# need to make a copy
UEFIFILE_VAR="/home/akashi/x86/OVMF_VARS.fd"
#UEFIFILE_VAR="/home/akashi/x86/ovmf_var.img"

# default
KERNFILE="/home/akashi/x86/build/kernel_416/arch/x86/boot/bzImage"

#ROOTDIR="/opt/buildroot/16.11_x86"
ROOTDIR="/opt/buildroot/16.11_x86_64"
ROOTFILE="/home/akashi/x86/build/br-16.11_64/images/rootfs.ext2"

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

print_usage() {
	echo `basename $0` [-glLnuU9]
	echo "  g: graphic"
	echo "  l: kernel boot with UEFI"
	echo "  L: kernel boot without UEFI"
	echo "  n: no execute, echoing command"
	echo "  u: kernel boot with UEFI"
	echo "  U: soly UEFI"
	echo "  9: 9P filesystem"
	exit 1
}

while getopts 9glLnuU OPT
do
	case ${OPT} in
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

if [ x$Lflag == x"" ] ; then
	FIRM="-pflash ${UEFIFILE}"
#	FIRM="-drive if=pflash,format=raw,readonly,file=${UEFIFILE}"
#	FIRM="${FILE} -drive if=pflash,format=raw,file=${UEFIFILE_VAR}"
	FIRM="-drive if=pflash,format=raw,file=${UEFIFILE_VAR}"
	FIRM="${FILE} -drive if=pflash,format=raw,readonly,file=${UEFIFILE}"
fi

if [ x$gflag != x"" ] ; then
	PARAMS=
else
	PARAMS=-nographic
fi

if [ x$nflag != x"" ] ; then
	ECHO=echo
fi

CMD="${SUDO} ${QEMU} -enable-kvm \
	-M q35 -smp cpus=2 -cpu ${CPU} -m 1024M \
	${PARAMS} \
	${FIRM} \
	${ROOTDEV} \
	${NETWORK} \
	-net none \
	-device e1000,netdev=net0 \
	-netdev user,id=net0 \
	-rtc base=localtime"

#-nographic \
#-curses \
#-serial stdio \

if [ x$lflag != x"" ] || [ x$Lflag != x"" ] ; then
	${ECHO} ${CMD} ${KERNEL} -append "${CMDLINE}"
else
	${ECHO} ${CMD}
fi

#echo DONE
