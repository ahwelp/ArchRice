#https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_T450s

#Locale info
  ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
  echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
  echo "pt_BR ISO-8859-1" >> /etc/locale.gen
  localectl set-locale LANG=pt_BR.UTF-8
  locale-gen

#Base network
  pacman -S --noconfirm networkmanager
  systemctl enable NetworkManager

#Wired network
  interface=`ip address | grep ': ' | cut -d' ' -f2 | cut -d':' -f 1 | grep enp`
  echo "auto $interface" >> /etc/network/interfaces
  echo "iface $interface inet dhcp" >> /etc/network/interfaces
  echo "nameserver 1.1.1.1" > /etc/resolv.conf

#Some x-things
  pacman -S --noconfirm xorg-server
  pacman -S --noconfirm xorg-xinit
  pacman -S --noconfirm xcompmgr
  pacman -S --noconfirm xorg-xsetroot

#System Helpers
  pacman -S --noconfirm man
  pacman -S --noconfirm curl
  pacman -S --noconfirm upower
  pacman -S --noconfirm wget
  pacman -S --noconfirm arandr
  pacman -S --noconfirm ntfs-3g
  
#Audio Configuration - F*** Why so hard? It's just sound
  pacman -S --noconfirm alsa-firmware #Just to be shure
  pacman -S --noconfirm alsa-utils #The main package
    usermod -a -G audio $SUDO_USER #Add the user on the group
  echo "options snd_hda_intel index=1,0" > /etc/modprobe.d/thinkpad-t450s.conf #I use a think pad, sooo...

#FruFru things
  pacman -S --noconfirm feh
  pacman -S --noconfirm vlc
  pacman -S --noconfirm nemo
  pacman -S --noconfirm zathura

#The dev  
  pacman -S --noconfirm git
    sudo -u $SUDO_USER git config --global user.email 'ahwelp@test.com'
    sudo -u $SUDO_USER git config --global user.name "ahwelp"

  pacman -S --noconfirm openssh
  pacman -S --noconfirm openconnect
  #pacman -S --noconfirm docker
  #pacman -S --noconfirm docker-compose
  


#A browser
  git clone https://aur.archlinux.org/brave-bin.git /usr/src/brave-bin
    chmod -R 777 /usr/src/brave-bin
    cd /usr/src/brave-bin
    sudo -u $SUDO_USER makepkg -si

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
  
  if [ "$USER" == "root" ] && [ "$SUDO_USER" == "root" ]; then
    userdir='/root/'
  elif [ "$USER" != "root" ]; then
    userdir="/home/$USER/"
  else	
    userdir="/home/$SUDO_USER/"
  fi
  
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/bash_login > $userdir/.bash_login
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/bashrc > $userdir/.bashrc
  curl https://raw.githubusercontent.com/ahwelp/arch_rice/master/dotfiles/xinitrc > $userdir/.xinitrc
  
  mkdir -p $userdir/.config/wallpapers
  
