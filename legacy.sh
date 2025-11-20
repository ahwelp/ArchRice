#!/bin/bash
set -e

# Core info
DISK="/dev/sda"
HOST_NAME="<HOST_NAME>"
ROOT_PASSWORD="<SECRET>"

# User info
USER="<USERNAME>"
USER_PASS="<SECRET>"

# Location info
LOCALE_1="<LOCALE_1>"   # pt_BR.UTF-8 UTF-8
LOCALE_2="<LOCALE_2>"   # pt_BR ISO-8859-1
TIME_ZONE="<TIME_ZONE>" # America/Sao_Paulo

# Disk geometry
#printf "g\nn\n1\n\n+4G\nt\n1\n82\nn\n2\n\n\nw\n" | fdisk "$DISK"
sgdisk -n 1:2048:+1M -t 1:ef02 "$DISK"
sgdisk -n 2:0:+4G -t 2:8200 "$DISK"
sgdisk -n 3:0:0 -t 3:8300 "$DISK"

sleep 2

#Swap
mkswap ${DISK}2
swapon ${DISK}2

# Disk File Systems
mkfs.ext4 -F ${DISK}3

#Install
mount --mkdir ${DISK}2 /mnt

pacstrap -K arch base base-devel linux linux-firmware man curl grub os-prober networkmanager qemu-guest-agent ntfs-3g vim git 
genfstab -U /mnt >> /mnt/etc/fstab

# Installing Bootloader
arch-chroot /mnt /bin/bash -c "grub-install --target=i386-pc $DISK"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"

# Manage Users
arch-chroot /mnt /bin/bash -c "echo root:$ROOT_PASSWORD | chpasswd"
arch-chroot /mnt /bin/bash -c "useradd -m -G wheel -s /bin/bash $USER"
arch-chroot /mnt /bin/bash -c "echo $USER:$USER_PASS | chpasswd"
arch-chroot /mnt /bin/bash -c "usermod -a -G whell $USER"
arch-chroot /mnt /bin/bash -c "sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers"

# Locale And Timezone
arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/$TIME_ZONE /etc/localtime"
arch-chroot /mnt /bin/bash -c "echo $LOCALE_1 >> /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "echo $LOCALE_2 >> /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "echo \"LC_ALL=$LOCALE_1\" >> /etc/enviroment"
arch-chroot /mnt /bin/bash -c "localectl set-locale LANG=$LOCALE_1"
arch-chroot /mnt /bin/bash -c "sudo -u $USER localectl set-locale LANG=$LOCALE_1"
arch-chroot /mnt /bin/bash -c "locale-gen"
arch-chroot /mnt /bin/bash -c "sudo -u $USER locale-gen"

# Network
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
arch-chroot /mnt /bin/bash -c "echo $HOST_NAME > /etc/hostname"

# Branding for style
arch-chroot /mnt /bin/bash -c "curl https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch > /usr/local/bin/neofetch"
arch-chroot /mnt /bin/bash -c "chmod +x /usr/local/bin/neofetch"
arch-chroot /mnt /bin/bash -c "neofetch > /etc/issue && echo \"(\l)\" >> /etc/issue"

# Install YAY
arch-chroot /mnt /bin/bash -c "git clone https://aur.archlinux.org/yay-bin.git /usr/src/yay-bin"
arch-chroot /mnt /bin/bash -c "pushd /usr/src/yay-bin"
arch-chroot /mnt /bin/bash -c "git config --add core.filemode false"
arch-chroot /mnt /bin/bash -c "sudo -u $USER makepkg -si --noconfirm"
arch-chroot /mnt /bin/bash -c "popd"

# Start other services
arch-chroot /mnt /bin/bash -c "systemctl enable qemu-guest-agent"
reboot
