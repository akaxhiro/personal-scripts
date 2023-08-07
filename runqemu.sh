#!/bin/bash
# version 2.0

SUDO=sudo

QEMU=/usr/bin/qemu-system-aarch64
#QEMU=/home/akashi/bin/qemu-system-aarch64
#QEMU=/home/akashi/x86/build/qemu-system/aarch64-softmmu/qemu-system-aarch64

# Default gic for qemu TF-A is version 2
# make sure that QEMU_USE_GIC_DRIVER=QEMU_GICV3
GICV="gic-version=3"
#GICV="gic-version=2"

VIRT="virtualization=on"
# Since 2020.?, U-Boot does panic with VIRT=on
#VIRT="virtualization=off"

#
SECURE="secure=off"
#SECURE="secure=on"

#IOMMU="iommu=none"
IOMMU="iommu=smmuv3"

if [ $(hostname) == "laputa" ] ; then
## for home
#QEMU_WORK=/home/akashi/arm/uefi
QEMU_WORK=/home/akashi/arm/work/qemu_work

#ROOTDIR=/opt/ubuntu/16.04
ROOTDIR=/opt/buildroot/17.08

# AHCI SCSI device
#SATAIMG=/opt/disk/xen_a64_test.img
SATAIMG=/media/akashi/9c294da6-3517-431a-9c23-057662ab07b6/opt_disk/xen_a64_test.img
####SATAIMG=/opt/disk/gpt_2part.img
#SATAIMG=/opt/disk/disk_nogpt.img

# AHCI SCSI device
#SATAIMG2=/opt/disk/debian-testing-arm64-netinst.iso
#SATAIMG2=/opt/disk/disk_nogpt.img
####SATAIMG2=/opt/disk/gpt_2part_2.img

# For EFI usb storage patch,
# add PCI-based xHCI controller
#USBIMG=/opt/disk/debian-testing-arm64-netinst.iso
:wq
#USBIMG=/opt/disk/gpt_2part_3.img
#USBIMG=/opt/disk/disk_nogpt.img
#USBIMG=/opt/disk/gpt_2part.img
#USBIMG2=/opt/disk/disk_nogpt.img
#USBIMG2=/opt/disk/gpt_2part.img
#USBIMG2=/opt/disk/gpt_2part_3.img
# must be a multiple of 512b
#MMCIMG=/opt/disk/debian-testing-arm64-netinst.iso
#MMCIMG=/opt/disk/gpt_2part_2.img

#
# NAT forwarding
#
#NETWORK="-nic user,model=virtio-net-pci"
#NETWORK="-netdev user,id=net0 -device virtio-net-pci,netdev=net0"
NETWORK="-netdev user,id=net1,hostfwd=tcp::10022-:22 -device virtio-net-pci,netdev=net1"

#
# Tap
#
#NETWORK="${NETWORK} -nic tap"
#NETWORK="-net tap,ifname=tap0,br=tmpbr0,script=/etc/qemu-ifup,downscript=/etc/qemu-ifdown"
#NETWORK="-netdev tap,id=net0,br=tmpbr0,helper=/usr/lib/qemu/qemu-bridge-helper -device virtio-net-pci,netdev=net0"

#
# Bridge with a helper
#
#NETWORK="-netdev bridge,id=net0,br=tmpbr0,helper=/usr/lib/qemu/qemu-bridge-helper -device virtio-net-pci,netdev=net0"

#
# Vhost?
#
#NETWORK="-netdev tap,id=net0,br=tmpbr0,helper=/usr/lib/qemu/qemu-bridge-helper,vhost=on -device virtio-net-pci,netdev=net0"
#NETWORK="-netdev tap,id=net0,vhost=on,script=no -device virtio-net-pci,netdev=net0"

#
# macvtap
#
#NETWORK="-netdev macvtap,ifname=macvtap0,id=net0,script=no -device virtio-net-pci,netdev=net0"

else
## for office work
#QEMU_WORK=/home/akashi/arm/armv8/linaro/uefi
QEMU_WORK=/home/akashi/arm/work/qemu_work

#ROOTDIR=/opt/ubuntu/16.04
ROOTDIR=/opt/ubuntu/16.04_arm64
#ROOTDIR=/opt/debian/jessie
#ROOTDIR=/media/akashi/root

#ROOTFSIMG=/opt/buildroot/16.11_64.ext4
ROOTFSIMG=/opt/disk/br202005.img

#
FLASH1_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/debug/flash1.img


#SATAIMG2=/opt/disk/uboot_sct.img
#SATAIMG2=/opt/disk/uboot_sct.img_bad
#SATAIMG2=/opt/disk/uboot_bootdev2.img
#SATAIMG2=/opt/disk/test_ext4.img

#MMCIMG=/opt/disk/uboot_sct.img
#MMCIMG=/opt/disk/test_vfat.img
#USBIMG=/opt/disk/ubuntu-18.04.1-server-arm64.iso
#USBIMG=/opt/disk/debian-testing-arm64-netinst.iso
#MMCIMG=/opt/disk/uboot_efi_env.img

# qemu default network
#hub 0
# \ hub0port1: user.0: index=0,type=user,net=10.0.2.0,restrict=off
# \ hub0port0: virtio-net-pci.0: index=0,type=nic,model=virtio-net-pci,macaddr=52:54:00:12:34:56
# old style (-netdev ... -device ...)
#NETWORK="-net user,id=mynet0,net=192.168.11.0/24 -net nic,model=virtio"

# new style
# User
#NETWORK="-netdev type=user,id=mynet0,dns=10.213.17.100,net=192.168.11.0/24 -device virtio-net-device,netdev=mynet0"

# Tap
# sync with /etc/my-qmeu-if[up|down]
#NETWORK="-netdev tap,id=mynet0,script=/etc/my-qemu-ifup,downscript=/etc/my-qemu-ifdown -device virtio-net-device,netdev=mynet0"

# Bridge
#NETWORK="-netdev bridge,br=armbr0,id=hn0,helper=/home/akashi/x86/build/qemu-system/qemu-bridge-helper -device virtio-net-pci,netdev=hn0"
#NETWORK="-netdev bridge,br=armbr0,id=hn0,helper=/home/akashi/x86/build/qemu-system/qemu-bridge-helper -device e1000,netdev=hn0"

## end of 'for office'
fi

#
# HD0 for UEFI System Partition
#

# For RedHat setup
# HD0=/opt/disk/redhat_a64_test.img

# For Xen Debian
# root:rootroot
# virtio block device
# have some of edk2 apps
#HD0=/opt/disk/xen_debian2.img
#HD1=/opt/disk/xen_debian2.img
#HD1=/opt/disk/xen_debian_guest.img
#HD1=/opt/disk/disk_nogpt.img
#HD0=/opt/disk/disk_nogpt.img

# Enable this for secboot test; data file system
#HD0=/home/akashi/tmp/secboot_test.img

#CDROM=/opt/disk/ubuntu-20.04.1-live-server-arm64.iso
#CDROM=/opt/disk/CentOS-8.2.2004-aarch64-minimal.iso
#CDROM=/opt/disk/rhel-8.2-aarch64-dvd.iso
#CDROM=/opt/disk/debian-10.6.0-arm64-netinst.iso
#CDROM=/opt/disk/debian-testing-arm64-netinst.iso

###
### UEFI specific
###

# cd work/qemu_work; creat_uefi.sh
UEFI_PATH=/home/akashi/arm/work/qemu_work/QEMU_EFI.rom
UEFI_VARS_PATH=/home/akashi/arm/work/qemu_work/QEMU_VARS.rom.centos
#UEFI_VARS_PATH=/home/akashi/arm/work/qemu_work/QEMU_VARS.rom.centos_sec

###
### U-boot
###

# please run create_flash.sh for extra env space
#UBOOT_PATH=/home/akashi/tmp/uboot_64/u-boot.bin
#UBOOT_PATH=/home/akashi/arm/work/qemu_work/u-boot.bin

# for ATF,
#ATF_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/debug/bl1.bin64
#ATF_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/debug/bl1.bin
#FIP_PATH=/home/akashi/arm/armv8/linaro/uefi/atf/build/qemu/debug/fip_uboot_secb.bin64

# moved binaries for backup
#ATF_PATH=/home/akashi/arm/uefi/atf/build/qemu/debug/bl1.bin
#FIP_PATH=/home/akashi/arm/uefi/atf/build/qemu/debug/fip.bin
ATF_PATH=/home/akashi/arm/build/atf_20201019/qemu/debug/bl1.bin
FIP_PATH=/home/akashi/arm/build/atf_20201019/qemu/debug/fip.bin

ATF_PATH=/home/akashi/arm/uefi/atf/build/qemu/debug/bl1.bin
FIP_PATH=/home/akashi/arm/uefi/atf/build/qemu/debug/fip.bin

###
### Linux loading
###
KDIR=none
#IMAGE=/home/akashi/arm/armv8/linaro/build/kernel_${KDIR}/arch/arm64/boot/Image
IMAGE=/home/akashi/arm/build/kernel_${KDIR}/arch/arm64/boot/Image

#DTB="-dtb /home/akashi/arm/armv8/linaro/uefi/atf/fdts/fvp-base-gicv3-psci.dtb"
#DTB="-dtb /home/akashi/tmp/uboot_64/fdt_qemu3.dtb"

CMDLINE="ip=dhcp loglevel=9 consolelog=9"
#CMDLINE="ip=192.168.10.11:192.168.10.1:192.168.10.1:255.255.255.0: loglevel=9 consolelog=9"
#CMDLINE="${CMDLINE} console=ttyAMA0 earlycon=pl011,0x90000000"
#CMDLINE="${CMDLINE} console=ttyAMA1 earlycon=pl011,0x90500000"

CMDLINE="${CMDLINE} S"
CMDLINE="${CMDLINE} init=/bin/sh"
#CMDLINE="${CMDLINE} initcall_debug"
#CMDLINE="${CMDLINE} crashkernel=256M"

#SWAPFILE=/home/akashi/arm/armv8/linaro/uefi/swap_512m.img

print_usage() {
	echo `basename $0` [-cdhkKlLnstuUv29] [\<kernerl_name\>]
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
	echo "  2: GIC version2"
	echo "  9: 9P root filesystem"
	exit 1
}

while getopts cdhkKlLnstuUv29 OPT
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
	2) G2flag=1;;
	9) R9flag=1;;
	*) print_usage;;
	esac
done
shift `expr ${OPTIND} - 1`

if [ $# -ne 0 ] ; then
	KDIR=$1
	# IMAGE=/home/akashi/arm/armv8/linaro/build/kernel_${KDIR}/arch/arm64/boot/Image
	IMAGE=/home/akashi/arm/build/kernel_${KDIR}/arch/arm64/boot/Image
fi

#
# Booting binary
#
if [ x$uflag != x"" ] ; then
	# But why?
	#VIRT="virtualization=off"

  if [ x$sflag != x"" ] ; then
	# all other binaries be loaded via semihosting
	# need chdir to TF-A builddir

#	UBOOT_PATH=${QEMU_WORK}/bl1.bin
#	BOOTBIN="-bios ${UBOOT_PATH}"

#	Non-semihost environment

	UBOOT_PATH=${QEMU_WORK}/flash_uboot.bin
	BOOTBIN="-bios ${UBOOT_PATH}"
	# for SCMI test,
	BOOTBIN="-bios /home/akashi/arm/uefi/atf/build/qemu/release/bl1.bin"

#	Old
#	BOOTBIN="-drive file=${UBOOT_PATH},format=raw,if=pflash,index=0"
#	BOOTBIN="${BOOTBIN} -drive file=${UBOOT_FIP_PATH},format=raw,if=pflash,index=1"
  else
	UBOOT_PATH=${QEMU_WORK}/u-boot.bin
	#UBOOT_PATH=/home/akashi/arm/build/uboot_202207/u-boot.bin
	#UBOOT_PATH=/home/akashi/arm/build/uboot_bootmgr/u-boot.bin
	#UBOOT_PATH=/home/akashi/arm/build/uboot_menu/u-boot.bin
	#UBOOT_PATH=/home/akashi/arm/build/uboot_usb_mas/u-boot.bin
	UBOOT_PATH=/home/akashi/arm/build/uboot_scmi/u-boot.bin
#	UBOOT_PATH=/home/akashi/arm/build/uboot_scmi_202304/u-boot.bin
#	64MB fat image doesn't work
# 	UBOOT_PATH=${QEMU_WORK}/u-boot_64mb.bin

	BOOTBIN="-bios ${UBOOT_PATH}"
#	BOOTBIN="-drive file=${UBOOT_PATH},format=raw,if=pflash,index=0"
  fi
else
  if [ x$sflag != x"" ] ; then
	BOOTBIN="-drive file=${ATF_PATH},format=raw,if=pflash,index=0"
	BOOTBIN="${BOOTBIN} -drive file=${FIP_PATH},format=raw,if=pflash,index=1"
  else
	#BOOTBIN="-bios ${UEFI_PATH}"
	BOOTBIN="-drive if=pflash,format=raw,readonly=on,file=${UEFI_PATH},index=0"
	BOOTBIN="${BOOTBIN} -drive if=pflash,format=raw,file=${UEFI_VARS_PATH},index=1"
  fi
fi

if [ x$hflag != x"" ] ; then
	SWAPDEV="-drive file=${SWAPFILE},cache=none,if=virtio,format=raw"
fi

#
# CPU feature selection
#
if [ x$G2flag != x"" ] ; then
	GICV="gic-version=2"
fi

if [ x$sflag != x"" ] ; then
	SECURE="secure=on"
fi

#
# monitor & serial
#
if [ x$tflag != x"" ] ; then
	# for telnet,
	#SERIAL="-serial telnet:localhost:1234,server,nowait"
	# for nc -l,
	#SERIAL="-serial telnet:localhost:1234,nowait"
	#SERIAL="${SERIAL} -serial telnet:localhost:1235,server,nowait"

	# connect via telnet
	# gnome-terminal -- telnet localhost 4444
	TELNET="telnet::4444,server"
	SERIAL="-monitor stdio -serial ${TELNET},nowait"
	#SERIAL="-monitor ${TELNET} -serial stdio"
	#SERIAL="-serial mon:${TELNET}"

	# Test for client mode
	SERIAL="-monitor stdio -serial tcp:localhost:4444,server=off,reconnect=5"
else
	#SERIAL="-serial mon:stdio -boot menu=on"
	SERIAL="-serial mon:stdio"
fi

#
# rootfs and CMDLINE
#
if [ x$vflag != x"" ] ; then
ROOTFSIMG=/opt/disk/br202005.img
	CMDLINE="${CMDLINE} root=/dev/vda rootfstype=ext4 rw"
	VFS="-drive if=none,file=${ROOTFSIMG},id=hd0 -device virtio-blk-device,drive=hd0"
elif [ x$R9flag != x"" ] ; then
	#CMDLINE="${CMDLINE} root=baa rootfstype=9p rootflags=trans=virtio rw"
	CMDLINE="${CMDLINE} root=baa rootfstype=9p rootflags=trans=virtio,cache=loose rw"
	RFS9P="-fsdev local,id=baa,path=${ROOTDIR},security_model=none -device virtio-9p-device,fsdev=baa,mount_tag=/dev/root"
else
	#CMDLINE="${CMDLINE} root=/dev/nfs nfsroot=192.168.10.1:${ROOTDIR},tcp rw"
	CMDLINE="${CMDLINE} root=/dev/nfs nfsroot=192.168.10.107:${ROOTDIR},tcp rw"
	#CMDLINE="${CMDLINE} root=/dev/nfs nfsroot=10.0.2.2:${ROOTDIR},tcp rw"
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

#
# block devices
#
DISKS=""
if [ x${SATAIMG} != x"" ] ; then
	SATADISK="-device ich9-ahci,id=ahci \
		-device ide-hd,drive=my_hd,bus=ahci.0 \
		-drive if=none,id=my_hd,format=raw,file=${SATAIMG}"
#	SATADISK="-device virtio-scsi-pci,id=scsi0 \
#		-device scsi-hd,drive=drive0,bus=scsi0.0,channel=0,scsi-id=0,lun=0 \
#		-drive file=${SATAIMG},if=none,id=drive0,format=raw"
	DISKS="${DISKS} ${SATADISK}"
fi
if [ x${SATAIMG2} != x"" ] ; then
	SATADISK2="-device ide-hd,drive=my_hd2,bus=ahci.1 \
		-drive if=none,id=my_hd2,format=raw,file=${SATAIMG2}"
#	another controller
#	SATADISK2="-device ich9-ahci,id=ahci2 \
#		-device ide-hd,drive=my_hd2,bus=ahci2.0 \
#		-drive if=none,id=my_hd2,format=raw,file=${SATAIMG2}"
#	SATADISK2="-device scsi-hd,drive=drive1,bus=scsi0.0,channel=0,scsi-id=0,lun=1 \
#		-drive file=${SATAIMG2},if=none,id=drive1,format=raw"
	DISKS="${DISKS} ${SATADISK2}"
fi
if [ x${MMCIMG} != x"" ] ; then
	MMCDISK=" -device sdhci-pci \
		-device sd-card,drive=my_sd \
		-drive if=none,id=my_sd,format=raw,file=${MMCIMG}"
	DISKS="${DISKS} ${MMCDISK}"
fi
if [ x${CDROM} != x"" ] ; then
	# DISKS="${DISKS} -cdrom ${CDROM}"
	# to detect CDROM first -> not work yet
	DISKS="-cdrom ${CDROM} ${DISKS}"
fi
# Order of HD0 and HD1 is important
if [ x${HD1} != x"" ] ; then
	VDISK="-drive if=none,file=${HD1},format=raw,id=hd1 -device virtio-blk-device,drive=hd1"
	DISKS="${DISKS} ${VDISK}"
fi
if [ x${HD0} != x"" ] ; then
	VDISK="-drive if=none,file=${HD0},format=raw,id=hd0 -device virtio-blk-device,drive=hd0"
	DISKS="${DISKS} ${VDISK}"
fi
if [ x${Uflag} != x"" ] ; then
  if [ x${USBIMG} != x"" ] ; then
	#USBDISK="-device usb-ehci,id=ehci \
	USBDISK="-device qemu-xhci,id=xhci \
		-device usb-kbd,port=1 \
		-device usb-storage,drive=my_usbmass \
		-drive if=none,id=my_usbmass,format=raw,file=${USBIMG}"
	DISKS="${DISKS} ${USBDISK}"
  fi
  if [ x${USBIMG2} != x"" ] ; then
	#USBDISK="-device usb-ehci,id=ehci \
	#USBDISK2="-device qemu-xhci,id=xhci2 \
	USBDISK2=" \
		-device usb-storage,port=3,drive=my_usbmass2 \
		-drive if=none,id=my_usbmass2,format=raw,file=${USBIMG2}"
	DISKS="${DISKS} ${USBDISK2}"
  fi
fi

#
# gdb server
#
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

# Need chdir if semihosting
# echo changing curret directory to ${QEMU_WORK}
# cd ${QEMU_WORK}

# for SCMI test,
#cd /home/akashi/arm/uefi/atf/build/qemu/debug
cd /home/akashi/arm/uefi/out/bin

KERNBIN="-kernel ${IMAGE} ${DTB}"
# DEBUG for zephyr
#KERNBIN="-kernel /tmp/zephyr.elf"

CMD="${SUDO} ${QEMU} ${DEBUG} ${SERIAL} \
	-nographic \
	-boot menu=on \
	-machine virt,${GICV},${VIRT},${SECURE},${IOMMU} \
	-cpu cortex-a57 -smp 2 \
	-m 4G \
	-d unimp \
	-semihosting \
	-semihosting-config enable=on,target=native \
	${NETWORK} \
	${RFS9P} \
	${VFS} \
	${DISKS} \
	${SWAPDEV} \
	-rtc base=utc"

if [ x$Lflag != x"" ] ; then
	${ECHO} ${CMD} ${KERNBIN} -append "${CMDLINE}"
elif [ x$lflag != x"" ] ; then
	${ECHO} ${CMD} ${BOOTBIN} ${KERNBIN} -append "${CMDLINE}"
else
#	if [ x$tflag != x"" ] ; then
#		(sleep 1; ${ECHO} gnome-terminal -- telnet localhost 4444) &
#		${ECHO} ${CMD} ${BOOTBIN} ${DTB}
#	else
#		${ECHO} ${CMD} ${BOOTBIN} ${DTB}
#	fi

	${ECHO} ${CMD} ${BOOTBIN} ${DTB}
fi

#
# alternatives are:
#

#	-semihosting-config enable=on,target=native \
#	-machine virt,dumpdtb=/tmp/qemu.dtb \

#	-serial telnet:localhost:1234,server,nowait \
#	-serial pty \
#	-chardev tty,id=ptsX,path=/dev/pts/19 \
#	-device virtio-serial-device,chardev=ptsX \

#	-serial stdio \
#	-curses \
#	-nographic \
