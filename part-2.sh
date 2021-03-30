#!/bin/sh
## In /mnt

# Disk
DISK1="sda"
HOSTNAME="wicked"
SPACER=";;;;;;;;"

# Time zone
ln -sf /usr/share/zoneinfo/US/Central /etc/localtime && \
  echo "$SPACER Time zone [done]"

# Localization
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
  echo "en_US ISO-8859-1" >> /etc/locale.gen && \
  locale-gen && \
  echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
  echo "KEYMAP=us" > /etc/vconsole.conf && \
  echo "$SPACER Localization [done]"

# Network config
echo "$HOSTNAME" > /etc/hostname && \
  echo "$SPACER Network config [done]"

pacman -S --noconfirm grub networkmanager && \
  grub-install /dev/$DISK1 && \
  grub-mkconfig -o /boot/grub/grub.cfg && \
  echo "$SPACER Bootloader GRUB [done]"

systemctl enable NetworkManager

passwd
