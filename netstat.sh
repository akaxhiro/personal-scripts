#!/bin/sh

# rx data, tx data
echo -n `date +'%D %H:%M:%S(%s)'`','
cat /proc/net/dev | grep wlp2s0 | awk -e '{print $3 "," $11}'
