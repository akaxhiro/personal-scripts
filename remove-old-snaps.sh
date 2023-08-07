#!/bin/sh

# https://www.linuxuprising.com/2019/04/how-to-remove-old-snap-versions-to-free.html
# Also try:
# sudo snap set system refresh.retain=2

# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS
set -eu

LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
while read snapname revision; do
	snap remove "$snapname" --revision="$revision"
done
