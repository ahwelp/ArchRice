# arch_rice

```
#Create a new User
useradd ghost
passwd ghost
usermod -a -G whell ghost
```

```
#Bootloader things
bootctl install
uuid=`cat /etc/fstab | grep ext4 | grep '/' | cut -d $'\t' -f1 | cut -d '=' -f 2`
partuuid=`blkid | grep $uuid | cut -d' ' -f 7 | sed 's/\"//g'`
printf "default arch\ntimeout 2" >> /boot/loader/loader.conf
printf "title ArchLinux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=$partuuid rw" >> /boot/loader/entries/arch.conf

```
