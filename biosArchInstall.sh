# insatll script for arch!!!!
echo -e "\033[0;31m##############################################################\n"
echo "  BE SURE TO ONLY RUN THIS SCRIPT ON A LIVE INSTANCE OF ARCH"
echo -e "             OR YOU WILL SCREW UP YOUR SYSTEM!!!\n"
echo -e "##############################################################\033[0;0m\n"

ifProceed=n
read -p "Are you sure you want to proceed? [y/N] " ifProceed
echo
if [ "$ifProceed" != "y" ]; then
	exit
fi

# 1. boot media and check for internet connection
echo -e "\033[0;34m1. boot media and check for internet connection\033[0;0m"
echo -e "command: \033[0;31mping -c4 www.google.com\033[0;0m"
#ping -c4 www.google.com && echo done || exit
echo

# 2. ensure clock accuracy
echo -e "\033[0;34m2. ensure clock accuracy\033[0;0m"
echo -e "command: \033[0;31mtimedatectl set-ntp true\033[0;0m"
#timedatectl set-ntp true && echo done || exit
echo

# 3. handle storage devices
echo -e "\033[0;34m3. handle storage devices\033[0;0m"
echo find the main drive name:
echo -e "command: \033[0;31mlsblk\033[0;0m"
lsblk # (to find the main drive name, ex: /dev/sda)
echo

echo "this script will use /dev/sda as the main storage device"
read -p "proceed? [y/N] " ifProceed
if [ "$ifProceed" != y ]; then
	exit
fi

# 3.1. make partition table (these instructions are for UEFI systems)
echo -e "\033[0;34m3.1 make partition table\033[0;0m"
echo -e "command: \033[0;31mparted /dev/sda mklabel msdos\033[0;0m"
mkfs.ext4 /dev/sda # to erase the disk
parted /dev/sda mklabel msdos && echo done
echo

# 3.2. make partition scheme (512M for EFI, 20 for /, 8 for swap, rest of disk for /home)
# im sure theres a better way to do this...
#echo -e "\033[034m3.2 make partition scheme (512M /boot, 20G /, 8G swap, 100% /home)\033[0;0m"
#echo -e "command:"
#echo -e "\033[0;31mparted /dev/sda mkpart ESP fat32 1MiB 513MiB"
#echo -e "&& parted /dev/sda set 1 boot on"
#echo -e "&& parted /dev/sda mkpart primary ext4 513MiB 20.5GiB"
#echo -e "&& parted /dev/sda mkpart primary linux-swap 20.5GiB 28.5GiB"
#echo -e "&& parted /dev/sda mkpart primary ext4 28.5GiB 100%\033[0;0m"
#parted /dev/sda mkpart ESP fat32 1MiB 513MiB && parted /dev/sda set 1 boot on && parted /dev/sda mkpart primary ext4 513MiB 20.5GiB && parted /dev/sda mkpart primary linux-swap 20.5GiB 28.5GiB && parted /dev/sda mkpart primary ext4 28.5GiB 100%
parted /dev/sda mkpart primary ext4 1MiB 100MiB &&
parted /dev/sda set 1 boot on &&
parted /dev/sda mkpart primary ext4 100MiB 30GiB &&
parted /dev/sda mkpart primary linux-swap 30GiB 46GiB &&
parted /dev/sda mkpart primary ext4 46GiB 100%

echo -e "command: \033[0;31mparted /dev/sda print\033[0;0m"
parted /dev/sda print
echo done

# 3.3. format partitions
#echo -e "\033[0;34m3.3 format partitions\033[0;0m"
#echo -e "command:\033[0;31m"
#echo -e "mkfs.ext4 /dev/sda2 && mkfs.ext4 /dev/sda4"
#echo -e "&& mkfs.vfat -F32 /dev/sda1"
#echo -e "&& mkswap /dev/sda3 && swapon /dev/sda3\033[0;0m"
#mkfs.ext4 /dev/sda2 && mkfs.ext4 /dev/sda4 && mkfs.vfat -F32 /dev/sda1 && mkswap /dev/sda3 && swapon /dev/sda3 && echo done
#echo

mkfs.ext4 /dev/sda2 &&
mkfs.ext4 /dev/sda4 &&
mkswap /dev/sda3 &&
swapon /dev/sda3
echo done

# 3.4. mount partitions
echo -e "\033[0;34m3.4 mount partitions\033[0;0m"
echo -e "command: \033[0;31m"
echo -e "mount /dev/sda2 /mnt"
echo -e "&& mkdir /mnt/home && mount /dev/sda4 /mnt/home"
echo -e "&& mkdir /mnt/boot && mount /dev/sda1 /mnt/boot\033[0;0m"
mount /dev/sda2 /mnt && mkdir /mnt/home  && mount /dev/sda4 /mnt/home && mkdir /mnt/boot && mount /dev/sda1 /mnt/boot && echo done
echo

# 4. select a mirror
#echo -e "\033[0;34m4. get fastest mirrors\033[0;0m"
#echo -e "working..."
#echo -e "\033[0;31mcp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.original"
#echo -e "&& scp clay:~/mirrorlist /etc/pacman.d/mirrorlist\033[0;0m"
#cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.original #&& scp clay:~/mirrorlist /etc/pacman.d/mirrorlist && echo done
#cp /etc/pacman.d/mirrorlist /etc/pacman.d/rankthese # create this file for rankmirrors
#sed -i 's/^#Server/Server/' /etc/pacman.d/rankthese # remove all preceeding #'s to test all mirrors
#rankmirrors -n 6 /etc/pacman.d/rankthese > /etc/pacman.d/mirrorlist # create list of fastest 6 mirrors
#echo

# do this instead, using the cache server makes things SO MUCH FASTER
cp /root/arch/mirrorlist /etc/pacman.d/mirrorlist

# 5. install the base system
echo -e "\033[0;34m5. install the base system\033[0;0m"
echo -e "command: \033[0;31mpacstrap /mnt base base-devel\033[0;0m"
pacstrap /mnt base base-devel && echo done
echo

# 6. generate an fstab
echo -e "\033[0;34m6. generate and fstab\033[0;0m"
echo -e "command: \033[0;31mgenfstab -U /mnt > /mnt/etc/fstab\033[0;0m"
genfstab -U /mnt > /mnt/etc/fstab && echo done
echo

echo next step: arch-chroot
cp biosConfigure.sh /mnt/.
arch-chroot /mnt /bin/bash biosConfigure.sh

echo "copy wifi-menu file"
#cp /etc/netctl/wlps0-Josh\ W /mnt/etc/netctl/.

echo "unmount everything when done"

