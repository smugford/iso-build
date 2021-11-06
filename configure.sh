!/bin/bash
# Create Debian Base Using qemu/chroot
# needs to be run as root
sudo apt update
sudo apt install -y qemu qemu-kvm debootstrap
qemu-img create -f qcow2 debian.img 10G
sudo modprobe nbd max_part=8
sudo qemu-nbd --format=raw --connect=/dev/nbd0 debian.img
sudo sfdisk /dev/nbd0  << EOF
1024,82
;
EOF
sudo mkswap /dev/nbd0p1
sudo mkfs.ext4 /dev/nbd0p2
sudo modinfo nbd
sudo mount /dev/nbd0p2 /mnt/
sudo debootstrap --arch=amd64 --include="openssh-server vim" stable /mnt/ http://httpredir.debian.org/debian/
sudo mount --bind /dev/ /mnt/dev
sudo chroot /mnt/ /bin/sh << EOF
sudo mount -t proc none /proc
sudo mount -t sysfs none /sys
sudo apt install -y  linux-image-amd64 grub2
sudo grub-install /dev/nbd0 --force
sudo chpasswd <<<"smugford:password"
sudo echo "debian" | passwd --stdin debian
sudo echo "pts/0" >> /etc/securetty
sudo systemctl set-default multi-user.target
sudo echo "/dev/sda2 / ext4 defaults,discard 0 0" > /etc/fstab
sudo umount /proc/ /sys/ /dev/
EOF
sudo grub-install dev/nbd0 --root-directory=/mnt --modules="biosdisk part_msdos" --force
sudo sed -i 's/nbd0p2/sda2/g' /mnt/boot/grub/grub.cfg
sudo umount /mnt
sudo qemu-nbd --disconnect /dev/nbd0
