!/bin/bash
# Create Debian Base Using qemu/chroot
# needs to be run as root
sudo apt update
sudo apt install -y qemu qemu-kvm debootstrap
qemu-img create -f qcow2 debian.img 10G
sudo modprobe nbd max_part=8
qemu-nbd --format=raw --connect=/dev/nbd0 debian.img
sfdisk /dev/nbd0  << EOF
1024,82
;
EOF
mkswap /dev/nbd0p1
mkfs.ext4 /dev/nbd0p2
modinfo nbd
mount /dev/nbd0p2 /mnt/
debootstrap --arch=amd64 --include="openssh-server vim" stable /mnt/ http://httpredir.debian.org/debian/
mount --bind /dev/ /mnt/dev
sudo chroot /mnt/ /bin/sh << EOF
mount -t proc none /proc
mount -t sysfs none /sys
apt install -y  linux-image-amd64 grub2
grub-install /dev/nbd0 --force
sudo chpasswd <<<"smugford:password"
echo "debian" | passwd --stdin debian
echo "pts/0" >> /etc/securetty
systemctl set-default multi-user.target
echo "/dev/sda2 / ext4 defaults,discard 0 0" > /etc/fstab
umount /proc/ /sys/ /dev/
EOF
grub-install dev/nbd0 --root-directory=/mnt --modules="biosdisk part_msdos" --force
sudo sed -i 's/nbd0p2/sda2/g' /mnt/boot/grub/grub.cfg
sudo umount /mnt
sudo qemu-nbd --disconnect /dev/nbd0
