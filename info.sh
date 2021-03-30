#!/bin/sh

## Boot Mode
[ -d /sys/firmware/efi ] && BIOS_TYPE="uefi" ||  BIOS_TYPE="bios"
echo "==> Boot Mode: $BIOS_TYPE"
[ $(whoami) = "root" ] && disk -l | grep "Disk /dev" || sudo fdisk -l | grep "Disk /dev"
## Load keys
#loadkeys us

dirpath=$(cd $(dirname $0); pwd -P)
#echo $dirpathe
echo "==> Modify This File $dirpath/variables.sh"
