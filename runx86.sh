#!/bin/sh

SUDO="sudo -E"
#QEMU=/usr/bin/qemu-system-x86_64
# TODO: enable virtio-9p-pci
QEMU=/home/akashi/bin/qemu-system-x86_64
#QEMU=/home/akashi/x86/build/qemu-system/x86_64-softmmu/qemu-system-x86_64

#UEFIFILE="/home/akashi/x86/build/ovmf/Build/OvmfX64/DEBUG_GCC5/FV/OVMF.fd"

UEFIFILE="/home/akashi/x86/build/ovmf/Build/OvmfX64/DEBUG_GCC5/FV/OVMF_CODE.fd"
# need to make a copy
UEFIFILE_VAR="/home/akashi/x86/OVMF_VARS.fd"
#UEFIFILE_VAR="/home/akashi/x86/ovmf_var.img"

# anonymous version?
#UEFIFILE=/home/akashi/arm/work/qemu_work/OVMF_CODE.rom
#UEFIFILE_VAR=/home/akashi/arm/work/qemu_work/OVMF_VARS.rom

# ubuntu from /usr/share/OVMF/ovmf.fd
UEFIFILE=/home/akashi/x86/build/OVMF.fd

#run create_flash.sh at ~/x86/build
#UBOOT_PATH=/home/akashi/x86/build/u-boot.rom

#BUILD_ROM=y make O=...
UBOOT_PATH=/home/akashi/x86/build/uboot_qemu/u-boot.rom
#UBOOT_PATH=/home/akashi/x86/build/uboot_qemu32/u-boot.rom

# default
KERNFILE="/home/akashi/x86/build/kernel_516/arch/x86/boot/bzImage"

# block device for rootfs
ROOTFSIMG=/home/akashi/x86/build/br_2111/images/rootfs.ext2
# or filesystem
ROOTDIR="/opt/buildroot/21.11_x86_64"

#SATAIMG=/opt/disk/ubuntu_x86.img
#MMCIMG=/opt/disk/uboot_sct_x86.img

#CDROM=/opt/disk/ubuntu-20.04-live-server-amd64.iso

CMDLINE="debug earlyprintk=ttyS0 vga=normal"
CMDLINE="${CMDLINE} ip=dhcp"
#CMDLINE="${CMDLINE} crashkernel=256M"
CMDLINE="${CMDLINE} console=ttyS0"
#CMDLINE="${CMDLINE} efi=debug"
#CMDLINE="${CMDLINE} memblock=debug"

#
# office network
#
#NETWORK="-net user,id=mynet0,net=192.168.10.0/24 -net nic,model=virtio"
#NETWORK="-net nic,netdev=guest0 -netdev tap,id=guest0,ifname=tap0"
# temporarily for qemu 2.9
#NETWORK="-netdev bridge,br=armbr0,id=hn0 -device virtio-net-pci,netdev=hn0"
#NETWORK="-netdev bridge,br=armbr0,id=hn0,helper=/home/akashi/x86/build/qemu-system/qemu-bridge-helper -device virtio-net-pci,netdev=hn0"

#
# home network
#
# NAT
# echo 1 > /proc/sys/net/ipv4/ip_forward
# echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
NETWORK="-netdev user,id=net0,hostfwd=tcp::10022-:22 -device virtio-net-pci,netdev=net0"
#
# Tap/bridge
# sudo brctl addif tmpbr0 enp5s0
# run setup_bridge.sh; disable iptables on bridges
#NETWORK="-netdev tap,id=net0,br=tmpbr0,helper=/usr/lib/qemu/qemu-bridge-helper -device virtio-net-pci,netdev=net0"
#NETWORK="-netdev tap,id=net0,helper=/usr/lib/qemu/qemu-bridge-helper -device virtio-net-pci,netdev=net0"
#NETWORK="-netdev tap,id=net0,vhost=on,helper=/usr/lib/qemu/qemu-bridge-helper -device virtio-net-pci,netdev=net0"
#
# MacVTAP
# sudo ip link add link enp5s0 name macvtap0 address 52:54:00:b8:9c:58 \
#      type macvtap mode bridge (or vepa or private)
# sudo ip link set macvtap0 up
# dhclient macvtap0?
# ip link show macvtap0; to confirm the tap number
#TAPNUM=12
#TAPMAC=$(ip link show macvtap0 | grep link/ether | awk -e '{print $2}')
#TAPNUM=$(ip link show macvtap0 | head -1 | awk -e 'BEGIN{FS=":"} {print $1}')
#NETWORK="-netdev tap,id=net0,fd=3 -device virtio-net-pci,netdev=net0,mac=${TAPMAC}"
#NET_VTAP="3<> /dev/tap${TAPNUM}"

# MAcVTAP with vhost?
# Probably we don't have to specify vhostfd here
#NETWORK="-netdev tap,id=net0,fd=3,vhost=on,vhostfd=4 -device virtio-net-pci,netdev=net0,mac=52:54:00:0a:8a:c5"
#NET_VTAP="3<> /dev/tap${TAPNUM} 4<> /dev/vhost-net"

# VFIO passthrough
# NIC host address: 05:00.0, vendor/device ID: 10ec:8168
# sudo sh -c "echo 1 > /sys/module/vfio/parameters/enable_unsafe_noiommu_mode"
# sudo sh -c "echo -n 0000:05:00.0 > /sys/bus/pci/devices/0000\:05\:00.0/driver/unbind"
# sudo sh -c "echo -n 10ec 8168 > /sys/bus/pci/drivers/vfio-pci/new_id"
# ls /dev/vfio ; see noiommu-0
# sudo chmod a+rw /dev/vfio/noiommu-0
#NETWORK="-device vfio-pci,host=05:00.0"

# tap+Open VSwitch (as bridge)
# sudo ovs-vsctl add-port tmpovsbr0 enp5s0
#NETWORK="-netdev tap,id=net0,br=tmpovsbr0,script=/home/akashi/bin/ifup-ovs.sh,downscript=/home/akashi/bin/ifdown-ovs.sh -device virtio-net-pci,netdev=net0"

print_usage() {
	echo `basename $0` [-dglLnuU39]
	echo "  d: gdb debug"
	echo "  g: graphic"
	echo "  l: kernel boot with UEFI"
	echo "  L: kernel boot without UEFI"
	echo "  n: no execute, echoing command"
	echo "  u: u-boot"
	echo "  U: soly UEFI"
	echo "  3: 32-bit"
	echo "  9: 9P filesystem"
	exit 1
}

while getopts 39dglLnuU OPT
do
	case ${OPT} in
	d) dflag=1;;
	g) gflag=1;;
	l) lflag=1;;
	L) Lflag=1;;
	n) nflag=1;;
	u) uflag=1;;
	U) Uflag=1;;
	3) Sflag=1;;
	9) Pflag=1;;
	*) print_usage;;
	esac
done
shift `expr ${OPTIND} - 1`

if [ $# -ne 0 ] ; then
KERNFILE="/home/akashi/x86/build/kernel_$1/arch/x86/boot/bzImage"
fi
KERNEL="-kernel ${KERNFILE}"

if [ x$Pflag != x"" ] ; then
	ROOTDEV="-fsdev local,id=baa,path=${ROOTDIR},security_model=none \
		 -device virtio-9p-pci,fsdev=baa,mount_tag=/dev/root"
	CMDLINE="${CMDLINE} root=baa rootfstype=9p rootflags=trans=virtio rw"
else
#	ROOTDEV="-drive file=${ROOTDIR},format=raw,if=ide"
#	CMDLINE="${CMDLINE} root=/dev/sda rw"
#	CMDLINE="${CMDLINE} root=/dev/nfs nfsroot=192.168.10.1:${ROOTDIR} rw"
#	CMDLINE="${CMDLINE} root=/dev/nfs nfsroot=192.168.11.5:${ROOTDIR} rw"
#	CMDLINE="${CMDLINE} root=/dev/vda rootfstype=ext2"

        #CMDLINE="${CMDLINE} root=/dev/vda rootfstype=ext2 rw pci=earlydump,nobios,noacpi acpi=off"
        CMDLINE="${CMDLINE} root=/dev/vda rootfstype=ext2 rw"
        ROOTDEV="-drive if=none,file=${ROOTFSIMG},format=raw,id=hd0 -device virtio-blk-pci,drive=hd0"

        #CMDLINE="${CMDLINE} root=/dev/sda rootfstype=ext2 rw"
	#ROOTDEV="-device virtio-scsi-pci,id=dc0 \
        #        -device scsi-hd,drive=hd0,bus=dc0.0 \
        #	-drive if=none,file=${ROOTFSIMG},format=raw,id=hd0"

fi

if [ x$uflag != x"" ] ; then
	echo With U-boot
#	FIRM="-pflash ${UBOOT_PATH}"
	FIRM="-bios ${UBOOT_PATH}"
elif [ x$Lflag != x"" ] ; then
	echo Without any boot loader ...
else
	echo With UEFI
	# with UEFI
#	FIRM="-pflash ${UEFIFILE}"
	FIRM="-bios ${UEFIFILE}"
#	FIRM="-drive if=pflash,format=raw,readonly=on,file=${UEFIFILE}"
#	FIRM="${FILE} -drive if=pflash,format=raw,file=${UEFIFILE_VAR}"
	FIRM="-drive if=pflash,format=raw,file=${UEFIFILE_VAR}"
	FIRM="${FILE} -drive if=pflash,format=raw,readonly=on,file=${UEFIFILE}"

	#from native Ubuntu, /usr/share/ovmf/
	#FIRM="-bios /opt/disk/OVMF.fd"
fi

if [ x$Sflag != x"" ] ; then
	CPU=kvm32
	MACHINE=q35
else
	CPU=kvm64
	#MACHINE=pc
	# without PCI/ACPI
	#MACHINE=microvm
	CPU=host
	MACHINE=q35
fi

if [ x$gflag != x"" ] ; then
	PARAMS="-serial stdio"
	#PARAMS="-vga virtio -display gtk"
	#PARAMS="-serial pty -serial pty -monitor stdio"
else
	#PARAMS="-nographic -curses -serial mon:stdio"
	PARAMS="-nographic -curses -monitor stdio"
	#PARAMS="-nographic -curses -serial stdio"
	#PARAMS="-nographic -serial pty -serial pty -monitor stdio"
fi
PARAMS="-nographic -serial mon:stdio"

if [ x$dflag != x"" ] ; then
	DEBUG="-s -S"
fi

if [ x$nflag != x"" ] ; then
	ECHO=echo
fi

if [ x${SATAIMG} != x"" ] ; then
#DISKS="-device ide-hd,drive=disk,if=none \
#	-drive file=${SATAIMG},id=disk,format=raw"

#DISKS=" -device ich9-ahci,id=ahci \
#	-device ide-hd,drive=my_hd,bus=ahci.0 \
#	-drive if=none,id=my_hd,format=raw,file=${SATAIMG}"
DISKS="-hda ${SATAIMG}"
fi

if [ x${MMCIMG} != x"" ] ; then
MMCDISK="	-device sdhci-pci \
	-device sd-card,drive=my_sd \
	-drive if=none,id=my_sd,format=raw,file=${MMCIMG}"
DISKS="$DISKS $MMCDISK"
fi

if [ x${CDROM} != x"" ] ; then
DISKS="${DISKS} -cdrom ${CDROM}"
fi

###
###
###

#CMD="${QEMU} ${DEBUG} -enable-kvm \
#	-machine ${MACHINE},accel=kvm \
#	-smp cpus=2 -m 1G \
CMD="${QEMU} ${DEBUG} -enable-kvm \
	-M ${MACHINE} \
	-smp cpus=2 -cpu ${CPU} -m 1G \
	${PARAMS} \
	${FIRM} \
	${ROOTDEV} \
	${DISKS} \
	${NETWORK} \
	-rtc base=utc"

# qemu uses i440fx
#	-M q35 \
#
#	-M pc \

#-curses \
# for serial and graphic consoles
#-serial stdio \

#-rtc base=localtime

if [ x$lflag != x"" ] || [ x$Lflag != x"" ] ; then
	${ECHO} ${SUDO} bash -c \
		"${CMD} ${KERNEL} -append \"${CMDLINE}\" ${NET_VTAP}"
else
	${ECHO} ${SUDO} bash -c "${CMD} ${NET_VTAP}"
fi

#echo DONE
