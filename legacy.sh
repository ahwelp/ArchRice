#!/bin/bash
set -e

## ToDo
## Add user to groups to sudo

###############################################################################
# Core info ###################################################################
DISK="/dev/sda"
HOST_NAME="ArchServer" # ArchServer
ROOT_PASSWORD=`openssl rand -base64 16` # Root Password

###############################################################################
# User info ###################################################################
USER="<username>"
USER_PASS=`openssl rand -base64 16`

###############################################################################
# Location info ###############################################################
LOCALE_1="<LOCALE_1>" # pt_BR.UTF-8
LOCALE_2="<LOCALE_2>" # pt_BR.ISO-8859-1
TIME_ZONE="<TIMEZONE>" # America/Sao_Paulo

###############################################################################
echo "Setting up Machine" ######################################################
SILENT_LOG="$(mktemp)"
log(){ echo "============================"; echo $1; }
logt(){ echo "============================"; echo $1; sleep 2; }
fuck(){ swapoff /dev/sda1 2>/dev/null || true; umount -R /mnt 2>/dev/null || true; }
silence(){ exec 3>&1 4>&2; exec 1>"$SILENT_LOG" 2>&1; }
voice(){ exec 1>&3 2>&4; exec 3>&- 4>&-; }
show_buffer(){ cat "$SILENT_LOG"; }
clear_buffer(){ : > "$SILENT_LOG"; }
trap 'fuck $?' ERR

###############################################################################
log "Setting up host machine" #################################################
silence
timedatectl set-ntp true
pacman -Sy archlinux-keyring --noconfirm
pacman -Syy --noconfirm
voice
logt "Host Machine is Configured" #############################################

###############################################################################
log "Creating Disk Gemometry" #################################################
silence
wipefs -a $DISK
printf "o\nn\np\n1\n\n+4G\nt\n82\nn\np\n2\n\n\nw\n" | fdisk $DISK
voice
logt "Geometry done" ##########################################################

###############################################################################
log "Formating Partitions" ####################################################
silence
mkswap ${DISK}1 #Swap
swapon ${DISK}1 #Swap
mkfs.ext4 -F ${DISK}2 # Disk File Systems
voice
log "Disk configuration Done" #################################################

###############################################################################
log "Starting Installation" ###################################################
mount --mkdir ${DISK}2 /mnt
PACKAGES="base base-devel linux linux-firmware grub man curl os-prober iptables-nft"
PACKAGES="$PACKAGES networkmanager qemu-guest-agent ntfs-3g vim git openssh"
pacstrap -K /mnt $PACKAGES
genfstab -U /mnt >> /mnt/etc/fstab
logt "Instalation complete" ###################################################

###############################################################################
log "Installing Bootloader" ###################################################
arch-chroot /mnt /bin/bash -c "grub-install --target=i386-pc $DISK"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
logt "Boot Loader installed" #################################################

###############################################################################
log "Setting up user" #########################################################
# ToDo add the user to sudoers. It's not working with wheel
arch-chroot /mnt /bin/bash -c "echo root:$ROOT_PASSWORD | chpasswd"
arch-chroot /mnt /bin/bash -c "groupadd -f wheel && groupadd -f sudo"
arch-chroot /mnt /bin/bash -c "useradd -m -s /bin/bash $USER"
arch-chroot /mnt /bin/bash -c "sed -i \"s/^wheel:x:[0-9]\+:/wheel:x:998:${USER}/\" /etc/group"
arch-chroot /mnt /bin/bash -c "echo $USER:$USER_PASS | chpasswd"
arch-chroot /mnt /bin/bash -c "sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers"
logt "User configuration done" ################################################

###############################################################################
log "Locale And Timezone" #####################################################
arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/$TIME_ZONE /etc/localtime"
arch-chroot /mnt /bin/bash -c "echo $LOCALE_1 >> /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "echo $LOCALE_2 >> /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "echo \"LC_ALL=$LOCALE_1\" >> /etc/enviroment"
arch-chroot /mnt /bin/bash -c "localectl set-locale LANG=$LOCALE_1"
arch-chroot /mnt /bin/bash -c "sudo -u $USER localectl set-locale LANG=$LOCALE_1"
arch-chroot /mnt /bin/bash -c "locale-gen"
arch-chroot /mnt /bin/bash -c "sudo -u $USER locale-gen"
logt "Time Zone and location done" ############################################

###############################################################################
log "Setting Up Network" ######################################################
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
arch-chroot /mnt /bin/bash -c "echo $HOST_NAME > /etc/hostname"
logt "NetworkManager config done" #############################################

###############################################################################
log "Branding for style" ######################################################
arch-chroot /mnt /bin/bash -c "curl https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch > /usr/local/bin/neofetch"
arch-chroot /mnt /bin/bash -c "chmod +x /usr/local/bin/neofetch"
arch-chroot /mnt /bin/bash -c "neofetch > /etc/issue && echo \"(\l)\" >> /etc/issue"
logt "Style is done " #########################################################

###############################################################################
log "Start other services" ####################################################
arch-chroot /mnt /bin/bash -c "systemctl enable sshd"
arch-chroot /mnt /bin/bash -c "systemctl enable qemu-guest-agent"
log "Other services enabled" ##################################################

#log "Rebooting"
#reboot
