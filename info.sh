#!/bin/sh

## Boot Mode
[ $(whoami) = "root" ] && disk -l | grep "Disk /dev" || sudo fdisk -l | grep "Disk /dev"
## Load keys
#loadkeys us

dirpath=$(cd $(dirname $0); pwd -P)
#echo $dirpathe
echo "==> Modify This File $dirpath/variables.sh"
echo "==> Modify This File $dirpath/part-2.sh"
