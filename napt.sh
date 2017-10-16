#!/bin/sh
# http://www.ahref.org/tech/server/server-tips/334.html

gl_intf=eth0
lo_net='192.168.10.0/24'

echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/iptables -t nat -A POSTROUTING -o ${gl_intf} -s ${lo_net}  -j MASQUERADE

# details
# http://www.atmarkit.co.jp/ait/articles/1002/09/news119_2.html

################################################
#Blocking Private Address
################################################
#/sbin/iptables -A OUTPUT -o ${gl_intf} -d 10.0.0.0/8 -j DROP
#/sbin/iptables -A OUTPUT -o ${gl_intf} -d 172.16.0.0/12 -j DROP
/sbin/iptables -A OUTPUT -o ${gl_intf} -d 192.168.0.0/16 -j DROP
/sbin/iptables -A OUTPUT -o ${gl_intf} -d 127.0.0.0/8 -j DROP

# On local PCs
# gateway to 192.168.10.1
