#!/bin/bash
set -e

# Core info
DISK="/dev/sda"
HOST_NAME="<HOST_NAME>" #ArchServer
ROOT_PASSWORD="<SECRET>" # openssl rand -base64 16

# User info
USER="<USERNAME>"
USER_PASS="<SECRET>" # openssl rand -base64 16

# Location info
LOCALE_1="<LOCALE_1>"  # pt_BR.UTF-8 UTF-8
LOCALE_2="<LOCALE_2>"   # pt_BR ISO-8859-1
TIME_ZONE="<TIME_ZONE>" # America/Sao_Paulo

log(){ echo "============================"; echo $1; sleep 2; }    
fuck(){ swapoff /dev/sda1 2>/dev/null || true; umount -R /mnt 2>/dev/null || true; }
trap 'fuck $?' ERR

# Some setup
timedatectl set-ntp true
pacman -Sy archlinux-keyring --noconfirm
pacman -Syy --noconfirm

# Disk geometry
wipefs -a $DISK
printf "o\nn\np\n1\n\n+4G\nt\n82\nn\np\n2\n\n\nw\n" | fdisk $DISK

#Swap
mkswap ${DISK}1
swapon ${DISK}1

# Disk File Systems
mkfs.ext4 -F ${DISK}2

log "Disk configuration Done"

#Install
mount --mkdir ${DISK}2 /mnt

pacstrap -K /mnt base base-devel linux linux-firmware man curl grub os-prober networkmanager qemu-guest-agent ntfs-3g vim git 
genfstab -U /mnt >> /mnt/etc/fstab

log "Instalation complete"

# Installing Bootloader
arch-chroot /mnt /bin/bash -c "grub-install --target=i386-pc $DISK"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"

log "Boot Loader installed"

# Manage Users
# ToDo add the user to sudoers. It's not working with wheel
arch-chroot /mnt /bin/bash -c "echo root:$ROOT_PASSWORD | chpasswd"
arch-chroot /mnt /bin/bash -c "groupadd -f wheel && groupadd -f sudo"
arch-chroot /mnt /bin/bash -c "useradd -m -s /bin/bash $USER"
arch-chroot /mnt /bin/bash -c "sed -i \"s/^wheel:x:[0-9]\+:/wheel:x:998:${USER}/\" /etc/group"
arch-chroot /mnt /bin/bash -c "echo $USER:$USER_PASS | chpasswd"
arch-chroot /mnt /bin/bash -c "sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers"

log "User configuration done"

# Locale And Timezone
arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/$TIME_ZONE /etc/localtime"
arch-chroot /mnt /bin/bash -c "echo $LOCALE_1 >> /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "echo $LOCALE_2 >> /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "echo \"LC_ALL=$LOCALE_1\" >> /etc/enviroment"
arch-chroot /mnt /bin/bash -c "localectl set-locale LANG=$LOCALE_1"
arch-chroot /mnt /bin/bash -c "sudo -u $USER localectl set-locale LANG=$LOCALE_1"
arch-chroot /mnt /bin/bash -c "locale-gen"
arch-chroot /mnt /bin/bash -c "sudo -u $USER locale-gen"

log "Time Zone and location done"

# Network
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
arch-chroot /mnt /bin/bash -c "echo $HOST_NAME > /etc/hostname"

log "NetworkManager config done"

# Branding for style
arch-chroot /mnt /bin/bash -c "curl https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch > /usr/local/bin/neofetch"
arch-chroot /mnt /bin/bash -c "chmod +x /usr/local/bin/neofetch"
arch-chroot /mnt /bin/bash -c "neofetch > /etc/issue && echo \"(\l)\" >> /etc/issue"

log "Style is done "

# Install YAY
arch-chroot /mnt /bin/bash -c "git clone https://aur.archlinux.org/yay-bin.git /usr/src/yay-bin"
arch-chroot /mnt /bin/bash -c "pushd /usr/src/yay-bin"
arch-chroot /mnt /bin/bash -c "git config --add core.filemode false"
arch-chroot /mnt /bin/bash -c "sudo -u $USER makepkg -si --noconfirm"
arch-chroot /mnt /bin/bash -c "popd"

log "Yay installation is done"

# Start other services
arch-chroot /mnt /bin/bash -c "systemctl enable qemu-guest-agent"

log "Other services enabled"

log "Rebooting"
reboot
