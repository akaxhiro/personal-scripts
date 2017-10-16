#! /bin/sh
### BEGIN INIT INFO
# Provides: ARM Ltd
# Required-Start: $local_fs $network $syslog
# Should-Start:
# Required-Stop: $local_fs $network $syslog
# Should-Stop:
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
# Short-Description: FM Network Setup
# Description: FM Network Setup
#              Create TAP deivces and network bridge for Fast Models
#              See http://www.arm.com/products/tools/fast-models.php 
#              for more information.
### END INIT INFO

# This is an example of a Linux LSB conforming init script.
# See http://refspecs.freestandards.org/ for more information on LSB.

# $FastModels$

# source function library
if [ -e /etc/rc.d/init.d/functions ];then
    source /etc/rc.d/init.d/functions
elif [ -e /lib/lsb/init-functions ];then
    source /lib/lsb/init-functions
else
    echo 'Unable to find lsb functions'
fi
PATH=.:/sbin:/usr/sbin:/bin:/usr/bin
USERS="akashi"
NIC=eth1
PREFIX=ARM
BRIDGE=armbr0
start()
{
    # take down ethx
    ip addr flush $NIC
    ifconfig $NIC 0.0.0.0 promisc
    ifdown $NIC
    # create bridge
    brctl addbr $BRIDGE
    brctl addif $BRIDGE $NIC
    # create tap devices and add them into the bridge
    for user in $USERS
    do
       tapctrl -n $PREFIX$user -a create -o $user -t tap
       ifconfig $PREFIX$user 0.0.0.0 promisc
       brctl addif $BRIDGE $PREFIX$user
    done
    ifconfig $NIC up
#    ifconfig $BRIDGE 0.0.0.0 promisc
    ifconfig $BRIDGE 192.168.10.1 promisc
    ip link set $BRIDGE up
# by aka
# NOTE!: the following 4 lines changed on 2016.3.16
#    killall -e dhclient
#    # wait process to finish
#    sleep 1s
#    dhclient $BRIDGE
    chmod a+rw /var/lib/dhcp/dhcpd.leases
    dhcpd armbr0
    ip addr flush $NIC
    ip addr show
}
stop()
{
   # take down the bridge
   ip addr flush $BRIDGE

   # remove the interfaces from the bridge
   brctl delif $BRIDGE $NIC

   # unset promiscous mode
   ifconfig $NIC 0.0.0.0 promisc

   for user in $USERS
   do
      brctl delif $BRIDGE $PREFIX$user
      tapctrl -n $PREFIX$user -a delete -o $user -t tap
   done
   ip link set $BRIDGE down
   # delete the bridge
   brctl delbr $BRIDGE

   # bring up the network
   ip link set $NIC up
   if [ -e /etc/init.d/network ]; then
       /etc/init.d/network restart
   elif [ -e /etc/init.d/network-manager ]; then
       /etc/init.d/network-manager restart
   else
       echo 'Unable to restart network, please do so manually'
   fi
   ip addr show
}
RETVAL=0
case "$1" in
    start)
           start
           ;;
    stop)
           stop
           ;;
    restart)
           stop
           start
           ;;
    *)
           echo -e "Usage: $0 {start|stop|restart}"
           RETVAL=1
esac

exit $RETVAL
# Script End
