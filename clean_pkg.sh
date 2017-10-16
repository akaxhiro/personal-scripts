#!/bin/sh

# http://askubuntu.com/questions/184117/requires-installation-of-untrusted-packages/185366

sudo apt-get clean
cd /var/lib/apt
sudo mv lists lists.old
sudo mkdir -p lists/partial
sudo apt-get clean 
sudo apt-get update

# better,
# sudp apt-get upgrate --fix-missing
