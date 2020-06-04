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

