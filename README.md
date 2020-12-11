# ArchRice

```
PREREQUISIT
Do the basic arch Install
  1 - Partitions (gdisk) UIEF (EF00) or Legacy
  2 - MkFs 
  3 - pacstrap /device base linux base-devel linux-firmware
  4 - genfstab -U /device >> /device/etc/fstab
  5 - arch-chroot /device 

INSTALLATION
  #Create a new User
  useradd ghost
  passwd ghost
  usermod -a -G whell ghost

  ./install.sh

```
MacBook Post
https://bbs.archlinux.org/viewtopic.php?pid=1919903#p1919903

## TodoList
* Configure notifications dunst
* DWM Blocks cmd 
* Get rid of systemd


## Services
* `systemctl start bluetooth`


## Guides
* Multimedia keys
  * xorg-xev
  * Read the keys and note down the presses
  * https://wiki.linuxquestions.org/wiki/Configuring_keyboards#Enabling_Keyboard_Multimedia_Keys
  * https://wiki.archlinux.org/index.php/Extra_keyboard_keys
  * https://wiki.archlinux.org/index.php/Udev
