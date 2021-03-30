#!/bin/sh

## Partitions
## TODO Multiple partitions, SINGLE PARTITION
## lsblk
# master boot record/ uefi
dirpath=$(cd $(dirname $0); pwd -P)
echo "Reading $dirpath/variables.sh"
. "$dirpath/variables.sh"

[ $BIOS_TYPE = "bios" ] && \
  echo "parted /dev/$DISK1 mklabel msdos" && \
  parted /dev/$DISK1 mklabel msdos && \
  echo "==> Label: MSDOS [done]" || echo "==> Label: MSDOS [failed]"
  
[ $BIOS_TYPE = "uefi" ] && \
  echo "parted /dev/$DISK1 mklabel gpt" && \
  parted /dev/$DISK1 mklabel gpt && \
  echo "==> Label: GPT [done]" || echo "==> Label: GPT [failed]"

## BOOT NO-SWAP
# /boot = 1GiB
# / = 100%
PARTED="parted /dev/"

[ $BIOS_TYPE = "bios" ] && [ $OPTION = "alt-1" ] && \
  echo "$PARTED$DISK1 mkpart primary $FS 0% 1GiB" && \
  $PARTED$DISK1 mkpart primary $FS 0% 1GiB && \
  echo "$PARTED$DISK1 set 1 boot on" && \
  $PARTED$DISK1 set 1 boot on && \
    echo "mkfs.$FS /dev/${DISK1}1" && \
    mkfs.$FS /dev/${DISK1}1 && \
  echo "$PARTED$DISK1 mkpart primary $FS 1GiB 100%" && \
  $PARTED$DISK1 mkpart primary $FS 1GiB 100% && \
    echo "mkfs.$FS /dev/${DISK1}2" && \
    mkfs.$FS /dev/${DISK1}2 && \
  echo "==> Partitions BIOS [done]" ||\
  echo "==> Partitions BIOS [failed]"

[ $BIOS_TYPE = "uefi" ] && [ $OPTION = "alt-1" ] && \
  $PARTED$DISK1 mkpart "EFI system partition" fat32 0% 261MiB && \
    mkfs.fat32 /dev/${DISK1}1 && \
  $PARTED$DISK1 set 1 esp on && \
    mkfs.$FS /dev/${DISK1}2 && \
  $PARTED$DISK1 mkpart "root partition" $FS 261MiB 100% && \
  echo "==> Partitions UEFI [done]" || \
  echo "==> Partitions UEFI [failed]"

lsblk

mount /dev/$ROOT_PART /mnt && \
  mkdir -p /mnt/boot && \
  mount /dev/$BOOT_PART /mnt/boot && \
  echo "==> Mounted partitions [done]" && \
  pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware && \
  cp $dirpath/part-2.sh /mnt/opt || \
  echo "==> Mounted partitions [failed]" \
    && umount /dev/$ROOT_PART && umount /dev/$BOOT_PART

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
genfstab -U /mnt >> /mnt/etc/fstab

## Inside root_partition
# Configure the system
arch-chroot /mnt /mnt/opt/part-2.sh
