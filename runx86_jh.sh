#!/bin/sh
# for jailhouse hosting

#CPU=host
CPU=kvm64

UEFIFILE="/home/akashi/x86/qemu_work/OVMF.fd"

KERNFILE="/home/akashi/x86/build/kernel_x86/arch/x86/boot/bzImage"
KERNFILE="/home/akashi/x86/build/kernel_kexec/arch/x86/boot/bzImage"

#ROOTDIR="/opt/buildroot/16.11_x86"
ROOTDIR="/opt/buildroot/16.11_x86_64"
ROOTFILE="/home/akashi/x86/build/br-16.11_64/images/rootfs.ext2"

CMDLINE="debug earlyprintk=ttyS0 vga=normal"
CMDLINE="${CMDLINE} ip=dhcp"
CMDLINE="${CMDLINE} crashkernel=64M"
#CMDLINE="${CMDLINE} console=ttyS0"
CMDLINE="${CMDLINE} nested=1"
CMDLINE="${CMDLINE} intel_iommu=on"
CMDLINE="${CMDLINE} memmap=66M\$0x3b000000"

#NETWORK="-net user,id=mynet0,net=192.168.10.0/24 -net nic,model=virtio"
#NETWORK="-net nic,netdev=guest0 -netdev tap,id=guest0,ifname=tap0"
# temporarily for qemu 2.9
#NETWORK="-netdev bridge,br=armbr0,id=hn0 -device virtio-net-pci,netdev=hn0"

print_usage() {
	echo `basename $0` [-9gU]
	echo "  9: 9P filesystem"
	echo "  g: graphic"
	echo "  U: soly UEFI"
	exit 1
}

while getopts 9gU OPT
do
	case ${OPT} in
	9) Pflag=1;;
	g) gflag=1;;
	U) Uflag=1;;
	*) print_usage;;
	esac
done
shift `expr ${OPTIND} - 1`

if [ $# -ne 0 ] ; then
echo "ARG1 " "$1"
KERNFILE="/home/akashi/x86/build/kernel_$1/arch/x86/boot/bzImage"
echo "KERN " ${KERNFILE}
fi

if [ x$Pflag != x"" ] ; then
	ROOTDEV="-fsdev local,id=baa,path=${ROOTDIR},security_model=none \
		 -device virtio-9p-pci,fsdev=baa,mount_tag=/dev/root"
	CMDLINE="${CMDLINE} root=baa rootfstype=9p rootflags=trans=virtio rw"
else
#	ROOTDEV="-drive file=${ROOTFILE},format=raw,if=ide"
#	CMDLINE="${CMDLINE} root=/dev/sda rw"
	CMDLINE="${CMDLINE} root=/dev/nfs nfsroot=192.168.10.1:${ROOTDIR} rw"
fi

if [ x$Uflag != x"" ] ; then
	FIRM="-pflash ${UEFIFILE}"
else
	KERNEL="-kernel ${KERNFILE}"
fi

if [ x$gflag != x"" ] ; then
	PARAMS=
else
	PARAMS=-nographic
fi


SUDO=sudo
#ECHO=echo
${ECHO} ${SUDO} ~/bin/qemu-system-x86_64 -enable-kvm \
-serial mon:stdio \
-serial telnet:localhost:1234,server,nowait \
-M q35,kernel_irqchip=split -smp cpus=4 -m 1G \
-cpu ${CPU},-kvm_pv_eoi,-kvm_steal_time,-kvm_asyncpf,-kvmclock,+vmx \
-device intel-iommu,intremap=on,x-buggy-eim=on \
${PARAMS} \
${FIRM} \
${KERNEL} \
-append "${CMDLINE}" \
${ROOTDEV} \
${NETWORK} \
-device e1000,netdev=net0 \
-netdev user,id=net0 \
-rtc base=localtime

# from Jailhouse README.md,
#-machine q35,kernel_irqchip=split -m 1G -enable-kvm \
#        -smp 4 -device intel-iommu,intremap=on,x-buggy-eim=on \
#        -cpu kvm64,-kvm_pv_eoi,-kvm_steal_time,-kvm_asyncpf,-kvmclock,+vmx \
#        -drive file=LinuxInstallation.img,format=raw|qcow2|...,id=disk,if=none \
#        -device ide-hd,drive=disk -serial stdio -serial vc \
#        -netdev user,id=net -device e1000e,addr=2.0,netdev=net \
#        -device intel-hda,addr=1b.0 -device hda-duplex

#-nographic \
#-curses \
#-serial stdio \

#echo DONE
