#!/bin/sh
#if [[ ! -d $1 ]] ; then
if [[ $# -ne 1 || ! -d $1 ]] ; then
  echo no/too args or invalid directory
  exit 1
fi
cd $1
sudo find . | sudo cpio -o -H newc | gzip -c > ../$(basename $1).img
#echo $(basename $1)
