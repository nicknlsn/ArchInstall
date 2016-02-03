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
echo thor > /etc/hostname
echo '#' > /etc/hosts
echo '# /etc/hosts: static lookup table for host names' >> /etc/hosts
echo '#' >> /etc/hosts
echo >> /etc/hosts
echo '#<ip-address>   <hostname.domain.org>   <hostname>' >> /etc/hosts
echo '127.0.0.1       localhost.localdomain   thor' >> /etc/hosts
echo '::1             localhost.localdomain   thor' >> /etc/hosts
echo >> /etc/hosts
echo '# End of file' >> /etc/hosts

# initramfs
#mkinitcpio -p linux

# set root password
#passwd

# install bootloader
pacman -S --noconfirm grub os-prober
grub-install --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# configure the network
pacman -S --noconfirm dialog wpa_actiond iw wpa_supplicant
systemctl enable netctl-auto@wlp6s0.service

# make sure openssh is there so we can log in again remotely
pacman -S --noconfirm openssh
systemctl enable sshd

# set root password
echo "set root password"
passwd

# add a user
echo "add user and set password"
useradd -m -G wheel,games,rfkill,users,uucp -s /bin/bash nick
passwd nick

# add nick to sudoers
# nano /etc/sudoers
# add after root ALL=(ALL) ALL
# nick ALL=(ALL) ALL
sed -i 's/root ALL=(ALL) ALL/root ALL=(ALL) ALL\nnick ALL=(ALL) ALL/' /etc/sudoers

# install nvidia driver
pacman -S --noconfirm nvidia nvidia-libgl

# install many other things
pacman -S --noconfirm i3 terminator htop screenfetch

#echo "exec i3" > /home/nick/.xinitrc

exit

