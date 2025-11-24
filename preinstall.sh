#!/bin/bash
###############################################################################
###########################  INSTALL SETUP  ###################################
###############################################################################

# Core info
DISK="/dev/sda"
HOST_NAME="ArchServer" # ArchServer
ROOT_PASSWORD=`openssl rand -base64 16` # Root Password

# User info
USER="<username>"
USER_PASS=`openssl rand -base64 16`

# Location info 
LOCALE_1="<LOCALE_1>" # pt_BR.UTF-8
LOCALE_2="<LOCALE_2>" # pt_BR.ISO-8859-1
TIME_ZONE="<TIMEZONE>" # America/Sao_Paulo

# Disk Geometry
BOOT_SIZE="+1G"  #+xGB to the size Recomended 1GB
SWAP_SIZE="+8G"  #+xGB to the size
BASE_SIZE=""     #Left Empty for the rest of the drive

# Creating Disk Gemometry
printf "g\nn\n\n\n+$BOOT_SIZE\nt\n1\n1\nn\n\n\n+$SWAP_SIZE\nt\n2\n19\nn\n\n\n${BASE_SIZE}\nw\n" | fdisk /dev/sda

# Formating
mkfs.fat -F 32 /dev/sda1 #Format in FAT 32 format
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4      /dev/sda3 #Format in ext4   format

# Setting up host machine
timedatectl set-ntp true
pacman -Sy archlinux-keyring --noconfirm
pacman -Syy --noconfirm

# Mounting folders
mount         /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot

# Arch Install
pacstrap -K /mnt base base-devel linux linux-firmware sudo git vim wget 
genfstab -U /mnt >> /mnt/etc/fstab
echo "/dev/sda2 none swap defaults 0 0" >> /mnt/etc/fstab

mount --types proc /proc /mnt/proc
mount --rbind /sys /mnt/sys
mount --rbind /dev /mnt/dev
mount --rbind /run /mnt/run

# Setting up user #########################################################
# ToDo add the user to sudoers. It's not working with wheel
arch-chroot /mnt chpasswd <<< "root:$ROOT_PASSWORD"
arch-chroot /mnt useradd -m -s /bin/bash "$USER"
arch-chroot /mnt usermod -aG wheel "$USER"
arch-chroot /mnt chpasswd <<< "$USER:$USER_PASS"
arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Execute the deed #########################################################
cp install.sh /mnt/home/$USER/install.sh
chmod +x /home/$USER/install.sh
arch-chroot /mnt /bin/bash -c "sudo -u $USER /home/$USER/install.sh"
