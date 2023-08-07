#!/bin/sh
ip link set $1 up
ovs-vsctl add-port tmpovsbr0 $1
