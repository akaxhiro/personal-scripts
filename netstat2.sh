#!/bin/sh

# rx data, tx data
echo -n `date +'%D %H:%M:%S(%s)'`','
ip -s link show wlp2s0 | awk -e '{print $1}' | tr "\n" "," | awk -e 'BEGIN {FS=","}{printf "%11d,%11d\n", $4, $6}'
