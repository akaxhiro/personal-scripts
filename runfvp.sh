#!/bin/bash

FVP_PATH=/home/akashi/arm/models/FVP_Base_AEMv8A-AEMv8A/models/Linux64_GCC-4.7
SIM=${FVP_PATH}/FVP_Base_AEMv8A-AEMv8A
QEMU=/home/akashi/bin/qemu-system-aarch64

#FW_DIR=/home/akashi/arm/armv8/linaro/uefi/atf/build/fvp/debug
FW_DIR=/home/akashi/arm/armv8/linaro/uefi/atf/build/fvp/release
BL1_BIN=bl1.bin
FW_BIN=fip.bin

#   Ard's kaslr-capable uefi; See below
#FW_BIN=/home/akashi/arm/armv8/linaro/uefi/ard/fip_fvp_kaslr.bin

IMAGE=../build/ub_1501/u-boot.elf

print_usage() {
	echo `basename $0` [-Ddkuv] [<kernerl_name>]
	echo "  D: Direct boot without secure framework"
	echo "  d: turn on cadi-server for DS-5/modeldebugger"
	echo "  k: KASLR test"
	echo "  u: U-boot instead of UEFI"
	echo "  v: VHE(ARMv8.1) enabled"
	exit 1
}

while getopts Ddkuv OPT
do
	case ${OPT} in
	D) Dflag=1;;
	d) dflag=1;;
	k) kflag=1;;
	u) uflag=1;;
	v) vflag=1;;
	*) print_usage;;
	esac
done
shift `expr ${OPTIND} - 1`

if [ $# -ne 0 ] ; then
KDIR=$1
rm Image
ln -s /home/akashi/arm/armv8/linaro/build/kernel_${KDIR}/arch/arm64/boot/Image ./Image
rm /home/akashi/arm/armv8/linaro/build/kernel
ln -s /home/akashi/arm/armv8/linaro/build/kernel_${KDIR} /home/akashi/arm/armv8/linaro/build/kernel
fi

if [ x$Dflag != x"" ] ; then
	IMAGES="-a cluster0.*=${IMAGE} -a cluster1.*=${IMAGE}"
fi

if [ x$uflag != x"" ] ; then
	FW_BIN=fip.bin.uboot
fi

if [ x$dflag != x"" ] ; then
	MOPTS="${MOPTS} --cadi-server"
fi

if [ x$kflag != x"" ] ; then
echo KASLR loader
	LOADER=ard/fip_fvp_kaslr.bin
else
	LOADER=${FW_DIR}/${FW_BIN}
fi

if [ x$vflag != x"" ] ; then
	HOSTv81=true
else
	HOSTv81=false
fi

cd /home/akashi/arm/armv8/linaro/uefi

${SIM} ${MOPTS} ${IMAGES} \
-C pctl.startup=0.0.0.0 \
-C bp.secure_memory=0 \
-C cluster0.NUM_CORES=2 \
-C cluster0.has_el2=true \
-C cluster0.has_arm_v8-1=${HOSTv81} \
-C cluster0.has_16k_granule=1 \
-C cluster1.NUM_CORES=2 \
-C cluster1.has_el2=true \
-C cluster1.has_arm_v8-1=${HOSTv81} \
-C cluster1.has_16k_granule=1 \
-C bp.tzc_400.diagnostics=1 \
-C cache_state_modelled=0 \
-C bp.pl011_uart0.uart_enable=1 \
-C bp.terminal_1.terminal_command="gnome-terminal --geometry=80x55+1000" \
-C bp.terminal_0.start_telnet=1 \
-C bp.terminal_1.terminal_command="gnome-terminal --geometry=80x55+1100+100" \
-C bp.terminal_1.start_telnet=0 \
-C bp.pl011_uart0.untimed_fifos=1 \
-C bp.hostbridge.interfaceName=ARM$USER \
-C bp.smsc_91c111.enabled=true \
-C bp.smsc_91c111.mac_address=00:11:22:33:44:55 \
-C bp.mmc.p_mmc_file=swap_512mFVP.img \
-C bp.secureflashloader.fname=${FW_DIR}/${BL1_BIN} \
-C bp.flashloader0.fname=${LOADER}


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
