#!/bin/bash

FVP_PATH=/home/akashi/arm/models/FVP_Base_AEMv8A-AEMv8A/models/Linux64_GCC-4.7
SIM=${FVP_PATH}/FVP_Base_AEMv8A-AEMv8A
# from inforcenter.arm.com
#FVP_PATH=/home/akashi/arm/models/Base_RevC_AEMv8A_pkg/models/Linux64_GCC-4.9
#SIM=${FVP_PATH}/FVP_Base_RevC-2xAEMv8A

QEMU=/home/akashi/bin/qemu-system-aarch64

# new for supporting KASLR

# 2018.8.30, console doesnt show any messages -> No problem. Use this.
FW_DIR=/home/akashi/arm/armv8/linaro/uefi/atf/build/fvp/release

# With this, assertion failure around pl011:237 at kdump
#FW_DIR=/home/akashi/arm/armv8/linaro/uefi/atf/build.0206/fvp/debug

#FW_DIR=/home/akashi/arm/armv8/linaro/uefi/atf/build.0804/fvp/debug
# old, but fine
# use the old one for kgdb due to ttyAMA1
#   and specify console=ttyAMA0
FW_DIR_kgdb=/home/akashi/arm/armv8/linaro/uefi/atf/build.0728/fvp/release

BL1_BIN=bl1.bin
FW_BIN=fip.bin
#FW_BIN=fip0619.bin

#   Ard's kaslr-capable uefi; See below
#FW_BIN=/home/akashi/arm/armv8/linaro/uefi/ard/fip_fvp_kaslr.bin

#IMAGE=../build/ub_1501/u-boot.elf
IMAGE=../build/uboot_201801/u-boot.elf

#ROOTFSIMG=/opt/buildroot/16.11_64.ext4
ROOTFSIMG=/opt/disk/tmp_fat.img

print_usage() {
	echo `basename $0` [-Ddgkuv123] [<kernerl_name>]
	echo "  D: Direct boot without secure framework"
	echo "  d: turn on cadi-server for DS-5/modeldebugger"
	echo "  g: enable kgdb"
	echo "  k: KASLR test"
	echo "  u: U-boot instead of UEFI"
	echo "  v: VHE(ARMv8.1) enabled"
	echo "  1: v8.1 enabled"
	echo "  2: v8.2 enabled"
	echo "  3: v8.3 enabled"
	exit 1
}

while getopts Ddgkuv123 OPT
do
	case ${OPT} in
	D) Dflag=1;;
	d) dflag=1;;
	g) gflag=1;;
	k) kflag=1;;
	u) uflag=1;;
	v) vflag=1;;
	1) vflag=1;;
	2) v2flag=1;;
	3) v3flag=1;;
	*) print_usage;;
	esac
done
shift `expr ${OPTIND} - 1`

cd /home/akashi/arm/armv8/linaro/uefi

if [ $# -ne 0 ] ; then
KDIR=$1
rm Image
ln -s /home/akashi/arm/armv8/linaro/build/kernel_${KDIR}/arch/arm64/boot/Image ./Image
rm /home/akashi/arm/armv8/linaro/build/kernel
ln -s /home/akashi/arm/armv8/linaro/build/kernel_${KDIR} /home/akashi/arm/armv8/linaro/build/kernel
fi

#if [ x$Dflag != x"" ] ; then
#	IMAGES="-a cluster0.*=${IMAGE} -a cluster1.*=${IMAGE}"
#fi

if [ x$uflag != x"" ] ; then
	FW_BIN=fip.bin.uboot
fi

if [ x$dflag != x"" ] ; then
	MOPTS="${MOPTS} --cadi-server"
fi

if [ x$gflag != x"" ] ; then
	FW_DIR=${FW_DIR_kgdb}
fi

if [ x$kflag != x"" ] ; then
# directly from Ard
	LOADER=ard/fip_fvp_kaslr.bin
# from Alex
#	LOADER=ard/QEMU_EFI.fd.KASLR
echo KASLR loader with ${LOADER}
else
	LOADER=${FW_DIR}/${FW_BIN}
fi

if [ x$vflag != x"" ] ; then
	HOSTv81=true
else
	HOSTv81=false
fi

if [ x$v2flag != x"" ] ; then
	HOSTv82=true
else
	HOSTv82=false
fi

if [ x$v3flag != x"" ] ; then
	HOSTv83=true
else
	HOSTv83=false
fi

${SIM} ${MOPTS} ${IMAGES} \
-C pctl.startup=0.0.0.0 \
-C bp.secure_memory=0 \
-C cluster0.NUM_CORES=4 \
-C cluster0.has_el2=true \
-C cluster0.has_arm_v8-1=${HOSTv81} \
-C cluster0.has_arm_v8-2=${HOSTv82} \
-C cluster0.has_arm_v8-3=${HOSTv83} \
-C cluster0.has_16k_granule=1 \
-C cluster1.NUM_CORES=4 \
-C cluster1.has_el2=true \
-C cluster1.has_arm_v8-1=${HOSTv81} \
-C cluster1.has_arm_v8-2=${HOSTv82} \
-C cluster1.has_arm_v8-3=${HOSTv83} \
-C cluster1.has_16k_granule=1 \
-C bp.tzc_400.diagnostics=1 \
-C cache_state_modelled=0 \
-C bp.pl011_uart0.uart_enable=1 \
-C bp.terminal_0.terminal_command="gnome-terminal --geometry=80x55+500" \
-C bp.terminal_0.start_telnet=1 \
-C bp.pl011_uart1.uart_enable=1 \
-C bp.terminal_1.terminal_command="gnome-terminal --geometry=80x30+600+100" \
-C bp.terminal_1.start_telnet=1 \
-C bp.pl011_uart2.uart_enable=1 \
-C bp.terminal_2.terminal_command="gnome-terminal --geometry=80x30+700+200" \
-C bp.terminal_2.start_telnet=0 \
-C bp.pl011_uart0.untimed_fifos=1 \
-C bp.hostbridge.interfaceName=ARM$USER \
-C bp.smsc_91c111.enabled=true \
-C bp.smsc_91c111.mac_address=00:11:22:33:44:55 \
-C bp.mmc.p_mmc_file=${ROOTFSIMG} \
-C bp.secureflashloader.fname=${FW_DIR}/${BL1_BIN} \
-C bp.flashloader0.fname=${LOADER}


#-C bp.secureflashloader.fname=${FW_DIR}/${BL1_BIN} \

# Verbose information
#--list-regs \
#--list-instances \
#--list-params \
#--list-memory \

# If we want a second tty,
#-C bp.terminal_1.start_telnet=1 \
#-C bp.terminal_2.terminal_command="gnome-terminal --geometry=80x50+1200+200" \
#-C bp.terminal_3.terminal_command="gnome-terminal --geometry=80x55+1300+0" \

# for test
#-C bp.virtioblockdevice.image_path=sd.img \
#-C bp.mmc.p_mmc_file=sd1m.img \
#-C bp.mmc.p_mmc_file=swap_512mFVP.img \
