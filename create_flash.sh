#!/bin/sh

BIN=/home/akashi/arm/build/uboot_$1/u-boot.bin
OBIN=./u-boot.bin

cat $BIN /dev/zero | dd iflag=fullblock conv=notrunc of=$OBIN bs=1M count=64
