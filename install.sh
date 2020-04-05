#https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_T450s

#UEFI Bootloader
  if [ ! -d "/boot/loader" ]; then
    bootctl install
    uuid=`cat /etc/fstab | grep ext4 | grep '/' | cut -d $'\t' -f1 | cut -d '=' -f 2`
    partuuid=`blkid | grep $uuid | cut -d' ' -f 7 | sed 's/\"//g'`
    printf "default arch\ntimeout 2" > /boot/loader/loader.conf
    printf "title ArchLinux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=$partuuid rw" > /boot/loader/entries/arch.conf
  else
    echo "There is a bootloader"
  fi

#Locale info
  ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
  echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
  echo "pt_BR ISO-8859-1" >> /etc/locale.gen
  localectl set-locale LANG=pt_BR.UTF-8
  locale-gen

#Base network
  pacman -S --noconfirm networkmanager
  systemctl enable NetworkManager
  echo "GhostArch" > /etc/hostname

#Wired network
  interface=`ip address | grep ': ' | cut -d' ' -f2 | cut -d':' -f 1 | grep enp`
  echo "auto $interface" >> /etc/network/interfaces
  echo "iface $interface inet dhcp" >> /etc/network/interfaces
  echo "nameserver 1.1.1.1" > /etc/resolv.conf

#Some x-things
  pacman -S --noconfirm xorg-server
  pacman -S --noconfirm xorg-xinit
  pacman -S --noconfirm xcompmgr
  pacman -S --noconfirm transset-df
  pacman -S --noconfirm xorg-xsetroot

#System Helpers
  pacman -S --noconfirm man
  pacman -S --noconfirm curl
  pacman -S --noconfirm wget
  pacman -S --noconfirm lm_sensors
  pacman -S --noconfirm arandr
  pacman -S --noconfirm ntfs-3g

#Define the user home dir and identity
  if [ "$USER" == "root" ] && [ "$SUDO_USER" == "root" ]; then
    userdir='/root/'
    username='root'
  elif [ "$USER" != "root" ]; then
    userdir="/home/$USER/"
    username=$USER
  else	
    userdir="/home/$SUDO_USER/"
    username=$SUDO_USER
  fi
  
#Audio Configuration - F*** Why so hard? It's just sound
  pacman -S --noconfirm alsa-firmware #Just to be shure
  pacman -S --noconfirm alsa-utils #The main package
    usermod -a -G audio $username #Add the user on the group
    
  #I use a ThinkPad, sooo...    
  product=`cat /sys/devices/virtual/dmi/id/product_version`
  if [ "$product" == "ThinkPad T450" ]; then
    echo "options snd_hda_intel index=1,0" > /etc/modprobe.d/thinkpad-t450s.conf 
  fi

#FruFru things
  pacman -S --noconfirm feh
  pacman -S --noconfirm vlc
  pacman -S --noconfirm nemo
  pacman -S --noconfirm zathura
  
#Branding
  curl https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch > /usr/local/bin/neofetch
    chmod +x /usr/local/bin/neofetch
  neofetch > /etc/issue
  echo "(\l)" >> /etc/issue
  
#The dev  
  pacman -S --noconfirm git
    sudo -u $username git config --global user.email 'ahwelp@test.com'
    sudo -u $username git config --global user.name "ahwelp"
  pacman -S --noconfirm openssh
  pacman -S --noconfirm openconnect
  
#The vim
  pacman -S --noconfirm vim
  wget https://github.com/ahwelp/arch_rice/raw/master/vim.tar -O /tmp/vim.tar
  rm -rf $userdir/.vim
  tar vzfx /tmp/vim.tar
  echo "source ~/.vim/.vimrc" > $userdir/.vimrc

#A browser
  git clone https://aur.archlinux.org/brave-bin.git /usr/src/brave-bin
    chmod -R 777 /usr/src/brave-bin
    cd /usr/src/brave-bin
    sudo -u $username makepkg -si

#The Suckless Dmenu
  git clone http://git.suckless.org/dmenu /usr/src/dmenu
    chmod -R 777 /usr/src/dmenu
    cd /usr/src/dmenu
    make && make install

#The Suckless DWM
  git clone http://git.suckless.org/dwm /usr/src/dwm
    chmod -R 777 /usr/src/dwm
    cd /usr/src/dwm
    make && make install

#The Suckless ST
  git clone http://git.suckless.org/st /usr/src/st
    chmod -R 777 /usr/src/st
    cd /usr/src/st
    make && make install

#The .files
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/bash_login > $userdir/.bash_login
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/bashrc > $userdir/.bashrc
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/xinitrc > $userdir/.xinitrc
  
#Download some wallpapers
  mkdir -p $userdir/.config/wallpapers
  wget https://github.com/ahwelp/arch_rice/raw/master/wallpapers/01.png  -O $userdir/.config/wallpapers/01.png
  wget https://github.com/ahwelp/arch_rice/raw/master/wallpapers/02.jpg  -O $userdir/.config/wallpapers/02.jpg
  wget https://github.com/ahwelp/arch_rice/raw/master/wallpapers/03.jpg  -O $userdir/.config/wallpapers/03.jpg
  wget https://github.com/ahwelp/arch_rice/raw/master/wallpapers/04.jpg  -O $userdir/.config/wallpapers/04.jpg
  wget https://github.com/ahwelp/arch_rice/raw/master/wallpapers/05.jpeg -O $userdir/.config/wallpapers/05.jpeg

#System information
  mkdir -p $userdir/.config/pcinfo
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/pcinfo/script.sh > $userdir/.config/pcinfo/script.sh

#Give back to Caesar what is Caesar's and to God what is God's
  chown -R $username $userdir
