#!/bin/sh
ovs-vsctl del-port tmpovsbr0 $1
ip link set $1 down
