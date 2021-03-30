#!/bin/sh

## Partitions
## TODO Multiple partitions, SINGLE PARTITION
## lsblk
# master boot record/ uefi
dirpath=$(cd $(dirname $0); pwd -P)
echo "$dirpath/variables.sh"
. "$dirpath/variables.sh"

[ $BIOS_TYPE = "bios" ] && \
#  && parted /dev/$DISK1 mklabel msdos \
  echo "==> Label: MSDOS [done]" || echo "==> Label: MSDOS [failed]"
  
[ $BIOS_TYPE = "uefi" ] && \
  parted /dev/$DISK1 mklabel gpt && \
  echo "==> Label: GPT [done]" || echo "==> Label: GPT [failed]"

## BOOT NO-SWAP
# /boot = 1GiB
# / = 100%
PARTED="parted /dev/"

[ $BIOS_TYPE = "bios" ] && [ $OPTION = "alt-1" ] && \
  $PARTED$DISK1 mkpart primary $FS 0% 1GiB && \
  $PARTED$DISK1 set 1 boot on && \
  $PARTED$DISK1 mkpart primary $FS 1GiB 100% && \
  echo "==> Partitions BIOS [done]" ||\
  echo "==> Partitions BIOS [failed]"

[ $BIOS_TYPE = "uefi" ] && [ $OPTION = "alt-1" ] && \
  $PARTED$DISK1 set 1 esp on && \
  $PARTED$DISK1 mkpart "EFI system partition" fat32 0% 261MiB && \
  $PARTED$DISK1 mkpart "root partition" $FS 261MiB 100% && \
  echo "==> Partitions UEFI [done]" || \
  echo "==> Partitions BIOS [failed]"

lsblk

mount /dev/$DISK1 /mnt && \
  mkdir /mnt/boot && \
  mount /dev/$BOOT_PART /mnt/boot && \
  echo "==> Mounted partitions [done]" && \
  pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware || \
  echo "==> Mounted partitions [failed]"

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

## Inside root_partition
# Configure the system
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt "$dirpath/part-2.sh"
