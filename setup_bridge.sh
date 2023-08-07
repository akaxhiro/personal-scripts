#!/bin/sh

#
# To allow for bridging VMs to physical network, disable iptables
#
echo 0 > /proc/sys/net/bridge/bridge-nf-call-arptables
echo 0 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables

#
# See
# https://qiita.com/mochizuki875/items/c69bb7fb2ef3a73dc1a9
#
# iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
