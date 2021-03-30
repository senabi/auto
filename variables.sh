#!/bin/sh


#FS="ext4"
[ -d /sys/firmware/efi ] && BIOS_TYPE="uefi" ||  BIOS_TYPE="bios"
FS="btrfs"

#Disk where partitions will be done
#NO SWAP, 
DISK1="sda"
BOOT_PART="${DISK1}1"
ROOT_PART="${DISK1}2"
OPTION="alt-1"
