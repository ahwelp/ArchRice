#https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_T450s

product=`cat /sys/devices/virtual/dmi/id/product_name`

#UEFI Bootloader
  if [ ! -d "/boot/loader" ]; then
    bootctl install
    uuid=`cat /etc/fstab | grep ext4 | grep '/' | cut -d $'\t' -f1 | cut -d '=' -f 2`
    partuuid=`blkid | grep $uuid | cut -d' ' -f 7 | sed 's/\"//g'`
    printf "default arch\ntimeout 2" > /boot/loader/loader.conf
    printf "title ArchLinux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=$partuuid rw irqpoll" > /boot/loader/entries/arch.conf
  else
    echo "There is a bootloader"
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
  pacman -S --noconfirm xorg-server
  pacman -S --noconfirm xorg-xinit
  pacman -S --noconfirm xcompmgr
  pacman -S --noconfirm transset-df
  pacman -S --noconfirm xorg-xsetroot xorg-xkill

#Create the xorg file And configure transparence
  Xorg :0 -configure
  mv /root/xorg.conf.new /etc/X11/xorg.conf
  printf 'Section "Extensions" \n Option  "Composite" "true" \n EndSection' >> /etc/X11/xorg.conf

#System Helpers
  pacman -S --noconfirm git
  pacman -S --noconfirm man 
  pacman -S --noconfirm curl 
  pacman -S --noconfirm wget 
  pacman -S --noconfirm lm_sensors 
  pacman -S --noconfirm arandr 
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
  git clone https://aur.archlinux.org/yay-bin.git /usr/src/yay-bin
  cd /usr/src/yay-bin
  git config --add core.filemode false
  chmod -R 777 /usr/src/yay-bin
  sudo -u $username makepkg -si --noconfirm

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
  pacman -S --noconfirm nemo
  #pacman -S --noconfirm zathura
  pacman -S --noconfirm transmission-cli
  
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
  sudo -u $username yay -S --noconfirm veracrypt-git
  sudo -u $username yay -S --noconfirm secure-delete

#The vim
  pacman -S --noconfirm vim
  sudo -u $username yay -S nerd-fonts-inconsolata --noconfirm
  #wget https://github.com/ahwelp/arch_rice/raw/master/vim.tar -O /tmp/vim.tar
  rm -rf $userdir/.vim
  tar vzfx vim.tar -C $userdir
  echo "source ~/.vim/.vimrc" > $userdir/.vimrc

#A browser
  git clone https://aur.archlinux.org/brave-bin.git /usr/src/brave-bin
    cd /usr/src/brave-bin
    git config --add core.filemode false
    chmod -R 777 /usr/src/brave-bin
    sudo -u $username makepkg -si --noconfirm



#The Suckless Dmenu
  git clone http://git.suckless.org/dmenu /usr/src/dmenu
    cd /usr/src/dmenu
    git config --add core.filemode false
    chmod -R 777 /usr/src/dmenu
      #patches
    make && make install

#The Suckless DWM
  git clone http://git.suckless.org/dwm /usr/src/dwm
    cd /usr/src/dwm
    chmod -R 777 /usr/src/dwm
    git config --add core.filemode false
      curl https://raw.githubusercontent.com/ahwelp/ArchRice/master/patches/st-font-adaptation.diff | git apply 
    make && make install

#The Suckless ST
  rm -rf /usr/src/st
  git clone http://git.suckless.org/st /usr/src/st
    cd /usr/src/st
    git config --add core.filemode false
    chmod -R 777 /usr/src/st
    git checkout tags/0.8.2
      curl https://st.suckless.org/patches/nordtheme/st-nordtheme-0.8.2.diff | git apply 
      #curl https://st.suckless.org/patches/dracula/st-dracula-0.8.2.diff | git apply 
      curl https://st.suckless.org/patches/scrollback/st-scrollback-0.8.2.diff | git apply 
      curl https://st.suckless.org/patches/scrollback/st-scrollback-mouse-0.8.2.diff | git apply 
      curl https://raw.githubusercontent.com/ahwelp/ArchRice/master/patches/st-font-adaptation.diff | git apply 
    make && make install

#The .files
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/bash_login > $userdir/.bash_login
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/bashrc > $userdir/.bashrc
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/xinitrc > $userdir/.xinitrc
  
#Download some wallpapers
  mkdir -p $userdir/.config/wallpapers
  tar vzfx wallpaper.tar $userdir/.config/wallpapers

#System information
  mkdir -p $userdir/.config/pcinfo
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/pcinfo/script.sh > $userdir/.config/pcinfo/script.sh
  chmod +x $userdir/.config/pcinfo/script.sh

#Give back to Caesar what is Caesar's and to God what is God's
  chown -R $username $userdir
