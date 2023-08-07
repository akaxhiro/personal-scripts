#!/bin/sh

sudo socat -d -d pty,link=/dev/ttyV0 tcp-listen:4444,reuseaddr,fork

#kvm
# -serial tcp:localhost:4444,server=off,reconnect=5
#

#
# minicom -p /dev/pts/2
