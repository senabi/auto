#!/bin/sh

## Partitions
## TODO Multiple partitions
# master boot record/ uefi

dirpath=$(cd $(dirname $0); pwd -P)
echo "Reading $dirpath/variables.sh"
. "$dirpath/variables.sh"

PARTED="parted /dev/$DISK1"
SPACER=";;;;;;;;;"


LABEL_MSDOS="$PARTED mklabel msdos"
LABEL_GPT="$PARTED mklabel gpt"
[ $BIOS_TYPE = "bios" ] && \
  echo "$LABEL_MSDOS" && $LABEL_MSDOS && \
  echo "$SPACER Label: MSDOS [done]" || \
  echo "$SPACER Label: MSDOS [failed]"
  
[ $BIOS_TYPE = "uefi" ] && \
  echo "$LABEL_GPT" && $LABEL_GPT && \
  echo "$SPACER Label: GPT [done]" || \ 
  echo "$SPACER Label: GPT [failed]"

## BOOT NO-SWAP
# /boot = 1GiB
# / = 100%
# BIOS
BIOS_MAKE_BOOTPART="$PARTED mkpart primary $FS 0% 1GiB"
BIOS_SET_BOOT_ON="$PARTED set 1 boot on"
BIOS_MAKE_BOOTPART_FS="mkfs.$FS /dev/${DISK1}1"
BIOS_MAKE_ROOTPART="$PARTED mkpart primary $FS 1GiB 100%"
BIOS_MAKE_ROOTPART_FS="mkfs.$FS /dev/${DISK1}2"
# UEFI
UEFI_MAKE_BOOTPART="$PARTED mkpart \"EFI system partition\" fat32 0% 1GiB"
UEFI_SET_BOOT_ON="$PARTED set 1 esp on"
UEFI_MAKE_BOOTPART_FS="mkfs.fat32 /dev/${DISK1}1"
UEFI_MAKE_ROOTPART="$PARTED mkpart \"root partition\" $FS 1GiB 100%"
UEFI_MAKE_ROOTPART_FS="mkfs.$FS /dev/${DISK1}2"

[ $BIOS_TYPE = "bios" ] && [ $OPTION = "alt-1" ] && \
  echo "$BIOS_MAKE_BOOTPART" && $BIOS_MAKE_BOOTPART && \
  echo "$BIOS_SET_BOOT_ON" && $BIOS_SET_BOOT_ON && \
  echo "$BIOS_MAKE_BOOTPART_FS" && $BIOS_MAKE_BOOTPART_FS && \
  echo "$BIOS_MAKE_ROOTPART" && $BIOS_MAKE_ROOTPART && \
  echo "$BIOS_MAKE_ROOTPART_FS" && $BIOS_MAKE_ROOTPART_FS && \
  echo "$SPACER Partitions BIOS [done]" ||\
  echo "$SPACER Partitions BIOS [failed]"

[ $BIOS_TYPE = "uefi" ] && [ $OPTION = "alt-1" ] && \
  echo "$UEFI_MAKE_BOOTPART" && $UEFI_MAKE_BOOTPART && \
  echo "$UEFI_SET_BOOT_ON" && $UEFI_SET_BOOT_ON &&\
  echo "$UEFI_MAKE_BOOTPART_FS" && $UEFI_MAKE_BOOTPART_FS && \
  echo "$UEFI_MAKE_ROOTPART" && $UEFI_MAKE_ROOTPART && \
  echo "$UEFI_MAKE_ROOTPART_FS" && $UEFI_MAKE_ROOTPART_FS \
  echo "$SPACER Partitions UEFI [done]" || \
  echo "$SPACER Partitions UEFI [failed]"

echo "$SPACER MOUNTING "

mount /dev/$ROOT_PART /mnt && \
  mkdir -p /mnt/boot && \
  mount /dev/$BOOT_PART /mnt/boot && \
  echo "$SPACER Mounted partitions [done]" && \
    pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware || \
  echo "$SPACER Mounted partitions [failed]" && \

## BOOT NO-SWAP
# /boot = 1GiB
# / = 100GiB
# /home = 100%
## / + /home 
## /{50GiB/100GiB} + separeted /home{100%} NO-SWAP
# NO SWAP

# mkfs.$FS /dev/
# mkswap /dev/swap_partition
# ## Mount the file systems
# mount /dev/root_partition /mnt
# swapon /dev/swap_partition

## Installation
sleep 2


## Inside root_partition
# Configure the system
cp $dirpath/part-2.sh /mnt/opt && \
genfstab -U /mnt >> /mnt/etc/fstab && \
arch-chroot /mnt /mnt/opt/part-2.sh && \
umount -R /mnt

echo "$SPACER If everything is OK reboot"
