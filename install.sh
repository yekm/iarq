#!/bin/bash -xe
# ap="cgdb cmake mc" hn=archdev bash -xe install.sh

trap 'umount -R /mnt' INT TERM EXIT

function fail {
    echo $@
    exit -1
}

echo hit ctrl-c
sleep 3

#hn=dev # host name (better with environment variables)
[ -z "$hn" ] && read hn
[ -z "$hn" ] && fail no hostname

#[ -z "$ap" ] && read ap # additional packages (better with environment variables)

#loadkeys
#setfont

sed -i '1s;^;Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch\n;' /etc/pacman.d/mirrorlist
#pacman -Syy #??
pacstrap /mnt --noconfirm linux base base-devel git vim openssh intel-ucode rxvt-unicode-terminfo $ap
#cp -v {,/mnt}/etc/pacman.d/mirrorlist #pacstrap does this

genfstab -L -p /mnt > /mnt/etc/fstab
echo 'en_US.UTF-8 UTF-8' > /mnt/etc/locale.gen
echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf
#echo KEYMAP=de-latin1-nodeadkeys >> /mnt/etc/vconsole.conf
#echo FONT=Lat2-Terminus16 >> /mnt/etc/vconsole.conf
ln -sf /usr/share/zoneinfo/Europe/Moscow /mnt/etc/localtime
echo "$hn" >>/mnt/etc/hostname
echo "127.0.1.1       $hn.localdomain        $hn" >>/mnt/etc/hosts
arch-chroot /mnt locale-gen
arch-chroot /mnt pacman -Syyu
arch-chroot /mnt timedatectl set-ntp true
arch-chroot /mnt systemctl enable dhcpcd
arch-chroot /mnt systemctl enable sshd
arch-chroot /mnt bootctl install
arch-chroot /mnt passwd
sed -i 's/^#\? \?PermitRootLogin .*/PermitRootLogin prohibit-password/' /mnt/etc/ssh/sshd_config

mkdir -p /mnt/root/.ssh
cat >/mnt/root/.ssh/authorized_keys <<EOF
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKlyu1QiAIIm4YyvutTMPBale6C0TAPMfZEax2GRK5ec/tZLyLz4PNzrH6G4+VUyCzrZvxM0VzlLax0rTnIjE0Y=
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDALePn5CnF7o3N6UgmXNq1OYeen5gS6KX5DCMp+Zo3TR0HXT8+R1iyCXRlEG989ZY3af4smxPkxL6Eh6acey9TreirCWVHxvMUkmBZpZnpDEsxZhhplsRmMZbaGb9d7xVgjjiQLwNu0W2Kn2x68KwBWHWMXQuLX7k3Lx0UilNu1LyQrbxzJXFwt2yfUwy+cgkRZuM6nOe4V0Md6WGSr9ZTSQCwCFBv5YLuIg4UotAjIX39vjA0yWu6YbAPaQerqQZaG9NVHn0G6f7CXTbwOW89g65sNc5jKgfjehoN2FJDQkm0FJa6YkyYEtzXlyBLbIqNOP1Jx69j+BFXN27010Vt
EOF

cat >/mnt/boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=/dev/disk/by-id/XXXXX rw zswap.enabled=1 zswap.zpool=z3fold sysrq_always_enabled=1 threadirqs clocksource=hpet
EOF
ls -la /dev/disk/by-id/ | grep "../../$(basename $(mount | grep /mnt/boot | cut -f1 -d' '))"

echo vim /mnt/boot/loader/entries/arch.conf

#umount -R /mnt
#read yolo
#[ -z "$yolo" ] && reboot

