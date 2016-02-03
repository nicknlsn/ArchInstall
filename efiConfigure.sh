#!/bin/bash
# configure the system after chroot

# uncomment en_US.UTF-8
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen


# generate locales
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# set timezone
ln -sf /usr/share/zoneinfo/America/Boise /etc/localtime
hwclock --systohc --utc

# set the hostname
echo archvm > /etc/hostname
echo '#' > /etc/hosts
echo '# /etc/hosts: static lookup table for host names' >> /etc/hosts
echo '#' >> /etc/hosts
echo >> /etc/hosts
echo '#<ip-address>   <hostname.domain.org>   <hostname>' >> /etc/hosts
echo '127.0.0.1       localhost.localdomain   archvm' >> /etc/hosts
echo '::1             localhost.localdomain   archvm' >> /etc/hosts
echo >> /etc/hosts
echo '# End of file' >> /etc/hosts

# initramfs
mkinitcpio -p linux

# set root password
passwd

# install bootloader
pacman -S dosfstools
bootctl --path=/boot install
echo 'title           Arch Linux' > /boot/loader/entries/arch.conf
echo 'linux           /vmlinuz-linux' >> /boot/loader/entries/arch.conf
echo 'initrd          /initramfs-linux.img' >> /boot/loader/entries/arch.conf
echo 'options         root=/dev/sda2 rw' >> /boot/loader/entries/arch.conf

echo 'timeout 1' > /boot/loader/loader.conf
echo 'default arch' >> /boot/loader/loader.conf

# configure the network
#systemctl enable dhcpcd@eno16777736.servive
systemctl enable dhcpcd@enp0s3.service
