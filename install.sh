#https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_T450s

#[ "$1" == "st" ] && ! terminal() 
#[ "$1" == "dwm" ] && ! dwm()  
#[ "$1" == "dmenu" ] && ! dmenu() 

#[ "$1" != "" ] && terminal && exit 

#The Suckless ST ##############################################################
terminal(){
  rm -rf /usr/src/st
  git clone http://git.suckless.org/st /usr/src/st
    cd /usr/src/st
    git config --add core.filemode false
    chmod -R 777 /usr/src/st
    git checkout tags/0.8.4
      curl https://st.suckless.org/patches/nordtheme/st-nordtheme-0.8.2.diff | git apply 
      #curl https://st.suckless.org/patches/dracula/st-dracula-0.8.2.diff | git apply 
      curl https://st.suckless.org/patches/scrollback/st-scrollback-20200419-72e3f6c.diff | git apply 
      curl https://st.suckless.org/patches/scrollback/st-scrollback-mouse-20191024-a2c479c.diff | git apply 
      curl https://raw.githubusercontent.com/ahwelp/ArchRice/master/patches/st-font-adaptation.diff | git apply 
    make && make install
}

# DWM installation ############################################################
dwm(){
  git clone http://git.suckless.org/dwm /usr/src/dwm
    cd /usr/src/dwm
    chmod -R 777 /usr/src/dwm
    git config --add core.filemode false
      curl https://dwm.suckless.org/patches/autostart/dwm-autostart-20200610-cb3f58a.diff | git apply
      #curl https://raw.githubusercontent.com/ahwelp/ArchRice/master/patches/st-font-adaptation.diff | git apply 
    make && make install
}

# YAY installation ############################################################
yayinstall(){
  git clone https://aur.archlinux.org/yay-bin.git /usr/src/yay-bin
  cd /usr/src/yay-bin
  git config --add core.filemode false
  chmod -R 777 /usr/src/yay-bin
  sudo -u $username makepkg -si --noconfirm
}


# DMENU installation ###########################################################
dmenu(){
  git clone http://git.suckless.org/dmenu /usr/src/dmenu
    cd /usr/src/dmenu
    git checkout tags/4.9
    git config --add core.filemode false
    chmod -R 777 /usr/src/dmenu
      #patches
      curl https://tools.suckless.org/dmenu/patches/grid/dmenu-grid-4.9.diff | git apply
      curl https://tools.suckless.org/dmenu/patches/center/dmenu-center-20200111-8cd37e1.diff | git apply
    make && make install
}

# Browser installation #########################################################
browser(){
  git clone https://aur.archlinux.org/brave-bin.git /usr/src/brave-bin
    cd /usr/src/brave-bin
    git config --add core.filemode false
    chmod -R 777 /usr/src/brave-bin
    sudo -u $username makepkg -si --noconfirm
}

product=`cat /sys/devices/virtual/dmi/id/product_name`


###############################################################################
 _____ _             _         _   _               
/  ___| |           | |       | | | |              
\ `--.| |_ __ _ _ __| |_ ___  | |_| | ___ _ __ ___ 
 `--. \ __/ _` | '__| __/ __| |  _  |/ _ \ '__/ _ \
/\__/ / || (_| | |  | |_\__ \ | | | |  __/ | |  __/
\____/ \__\__,_|_|   \__|___/ \_| |_/\___|_|  \___|

###############################################################################

# === UEFI Bootloader Setup ===
if [ ! -d "/boot/loader" ]; then
  echo "[INFO] Installing systemd-boot..."
  bootctl install

  # Detecta automaticamente a partição root montada em /
  rootdev=$(findmnt / -o SOURCE -n)

  # Obtém o PARTUUID (que o systemd-boot prefere)
  partuuid=$(blkid -s PARTUUID -o value "$rootdev")

  # Verifica se encontrou corretamente
  if [ -z "$partuuid" ]; then
    echo "[ERRO] Não foi possível detectar o PARTUUID da partição root ($rootdev)"
    echo "Verifique com: blkid $rootdev"
    exit 1
  fi

  # Cria arquivos do systemd-boot
  cat > /boot/loader/loader.conf <<EOF
default arch
timeout 2
editor no
EOF

  cat > /boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$partuuid rw
EOF

  echo "[OK] Bootloader configurado com root=PARTUUID=$partuuid"
else
  echo "[WARN] Já existe um bootloader instalado. Abortando para evitar sobrescrever."
  exit 0
fi


#Locale info ##May need to generate for the user too not just root
  ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
    echo "pt_BR ISO-8859-1" >> /etc/locale.gen
    echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
    echo "LC_ALL=pt_BR.UTF-8" >> /etc/enviroment
  localectl set-locale LANG=pt_BR.UTF-8 && sudo -u $username localectl set-locale LANG=pt_BR.UTF-8
  locale-gen && sudo -u $username locale-gen

#Macbook network firmware
  if [ "$product" == "MacBookAir1,1" ]; then
    sudo -u $username yay -S b43-firmware
  fi

#Base network
  pacman -S --noconfirm networkmanager
  systemctl enable NetworkManager
  echo "GhostArch" > /etc/hostname

#Wired network
  interface=`ip address | grep ': ' | cut -d' ' -f2 | cut -d':' -f 1 | grep enp`
  echo "auto $interface" >> /etc/network/interfaces
  echo "iface $interface inet dhcp" >> /etc/network/interfaces
  echo "nameserver 1.1.1.1" > /etc/resolv.conf

#Wireless network
  #https://wiki.archlinux.org/index.php/Netctl
  #sudo pacman -S netctl dialog

#Some x-things
  pacman -S --noconfirm xorg-server xorg-xinit
  pacman -S --noconfirm transset-df xcompmgr
  pacman -S --noconfirm xorg-xsetroot xorg-xkill

#Create the xorg file And configure transparence
  Xorg :0 -configure
  mv /root/xorg.conf.new /etc/X11/xorg.conf
  printf 'Section "Extensions" \n Option  "Composite" "true" \n EndSection' >> /etc/X11/xorg.conf

#System Helpers
  pacman -S --noconfirm git man curl
  pacman -S --noconfirm wget lm_sensors arandr 
  pacman -S --noconfirm ntfs-3g 

#Def ine the user home dir and identity
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
  
#YAY - Use with yay -S
  yayinstall

#Audio Configuration - F*** Why so hard? It's just sound
  pacman -S --noconfirm alsa-firmware #Just to be shure
  pacman -S --noconfirm alsa-utils #The main package
    usermod -a -G audio $username #Add the user on the group
  #I use this ThinkPad, sooo...    
  if [ "$product" == "20BUS3V100" ]; then
    echo "options snd_hda_intel index=1,0" > /etc/modprobe.d/thinkpad-t450s.conf 
  fi

#FruFru things
  pacman -S --noconfirm feh
  pacman -S --noconfirm vlc
  pacman -S --noconfirm nautilus
    #Dark Theme for GTK
    printf '[Settings] \n gtk-application-prefer-dark-theme = true ' >> /etc/gtk-3.0/settings.ini
  pacman -S --noconfirm zathura zathura-pdf-poppler
  pacman -S --noconfirm transmission-cli #transmission-gtk ( YAY transmission-remote-cli-git )
  pacman -S --noconfirm noto-fonts-emoji
    yay -S libxft-bgra #Color emoji fix
  
#Desktop Notifications
  pacman -S --noconfigm libnotify dunst
    mkdir ~/.config/dnust/
    curl https://raw.githubusercontent.com/LukeSmithxyz/voidrice/efa9fffae21abdcf207678655a446770082afd9a/.config/dunst/dunstrc > ~/.config/dnust/dunstrc


#Branding
  curl https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch > /usr/local/bin/neofetch
    chmod +x /usr/local/bin/neofetch
  neofetch > /etc/issue
  echo "(\l)" >> /etc/issue
  
#The dev  
  pacman -S --noconfirm git
    sudo -u $username git config --add user.email 'ahwelp@test.com'
    sudo -u $username git config --add user.name "ahwelp"
  pacman -S --noconfirm openssh 
  pacman -S --noconfirm openconnect

#The Secrets
  sudo -u $username yay -S --noconfirm veracrypt-git keepassxc

#The vim
  pacman -S --noconfirm vim
  sudo -u $username yay -S nerd-fonts-inconsolata --noconfirm
  rm -rf $userdir/.vim
  #tar vzfx vim.tar -C $userdir
  #echo "source ~/.vim/.vimrc" > $userdir/.vimrc

#A browser
  browser

#Install terminal
  dmenu

#Install terminal
  dwm

#Install terminal
  terminal

#The .files
dotfiles(){
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/bash_login > $userdir/.bash_login
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/bashrc > $userdir/.bashrc
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/xinitrc > $userdir/.xinitrc
}
  dotfiles

#Download some wallpapers
  mkdir -p $userdir/.config/wallpapers
  tar vzfx wallpaper.tar $userdir/.config/wallpapers

#System information
  mkdir -p $userdir/script
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/pcinfo/script.sh > $userdir/script/script.sh
  chmod +x $userdir/script/script.sh

#Give back to Caesar what is Caesar's and to God what is God's
  chown -R $username $userdir
