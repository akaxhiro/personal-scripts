#!/bin/sh

#sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

# for NFS mount, specify -o nolock
