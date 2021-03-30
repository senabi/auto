#!/bin/dash

## Boot Mode
if [ -d /sys/firmware/efi ]; then
    BIOS_TYPE="uefi"
else
    BIOS_TYPE="bios"
fi
echo "==> Boot Mode: $BIOS_TYPE"

## Load keys
loadkeys us

## Connect to the internet
# Update the system clock
timedatectl set-ntp true

## Partitions
## TODO Multiple partitions, SINGLE PARTITION
## lsblk
# master boot record/ uefi
FS="ext4"
FS="btrfs"
parted /dev/Xda mklabel msdos
parted /dev/Xda mklabel gpt
## BOOT
parted /dev/Xda mkpart primary $FS 1MiB 1GiB
[ $BIOS_TYPE = "bios" ] && parted /dev/Xda set 1 boot on
[ $BIOS_TYPE = "uefi" ] && parted /dev/Xda set 1 esp on
## / + /home 
# SWAP
parted /dev/Xda mkpart primary linux-swap 1GiB 5GiB
parted /dev/Xda mkpart primary $FS 5GiB 100%
## /{50GiB/100GiB} + separeted /home{100%} NO-SWAP
# NO SWAP
parted /dev/Xda mkpart primary $FS 1GiB 100GiB
parted /dev/Xda mkpart primary $FS 100GiB 100%
## make it bootable
parted /dev/Xda mkpart set 1 boot on


mkfs.$FS /dev/root_partition
mkswap /dev/swap_partition
## Mount the file systems
mount /dev/root_partition /mnt
swapon /dev/swap_partition

## Installation
pacstrap /mnt base base-devel linux-lts linux-lts-firmware

## Inside root_partition
# Configure the system
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt

# Time zone
ln -sf /usr/share/zoneinfo/US/Central /etc/localtime

# Localization
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Network config
echo "senabi" > /etc/hostname
