#!/bin/bash
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/zen0x00/mangowc-dots/main/install.sh)"
set -e

export TERM=xterm

read -rp "Target install disk (e.g. /dev/nvme0n1 or /dev/sda): " DISK
read -rp "Hostname: " HOSTNAME
read -rp "Username: " USERNAME
read -rp "Timezone (e.g. Asia/Kolkata): " TIMEZONE

# Prompt for root and user passwords (hidden input)
while true; do
	read -rsp "Root password: " ROOT_PASS
	echo
	read -rsp "Confirm root password: " ROOT_PASS_CONFIRM
	echo
	[ "$ROOT_PASS" = "$ROOT_PASS_CONFIRM" ] && break
	echo "Passwords do not match. Try again."
done

while true; do
	read -rsp "Password for user $USERNAME: " USER_PASS
	echo
	read -rsp "Confirm password for user $USERNAME: " USER_PASS_CONFIRM
	echo
	[ "$USER_PASS" = "$USER_PASS_CONFIRM" ] && break
	echo "Passwords do not match. Try again."
done

# Create GPT partitions: 1 = EFI, 2 = root (btrfs)
parted -s "$DISK" mklabel gpt \
	mkpart primary fat32 1MiB 512MiB \
	mkpart primary btrfs 512MiB 100% \
	set 1 esp on

# Detect partition name suffix (p for nvme devices, none for sdX)
if [[ "$DISK" =~ [0-9]$ ]]; then
	PART_SUFFIX="p"
else
	PART_SUFFIX=""
fi

EFI_PART="${DISK}${PART_SUFFIX}1"
ROOT_PART="${DISK}${PART_SUFFIX}2"

mkfs.fat -F32 "$EFI_PART"

mkfs.btrfs -f -L archpool "$ROOT_PART"
mount "$ROOT_PART" /mnt

# Create subvolumes
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@log

umount -l /mnt 2>/dev/null || true

mount -o subvol=@root,compress=zstd,noatime LABEL=archpool /mnt
mkdir -p /mnt/{home,.snapshots,var,var/log,boot}
mount -o subvol=@home,compress=zstd,noatime LABEL=archpool /mnt/home
mount -o subvol=@snapshots,compress=zstd,noatime LABEL=archpool /mnt/.snapshots
mount -o subvol=@var,compress=zstd,noatime LABEL=archpool /mnt/var
mkdir -p /mnt/var/log
mount -o subvol=@log,compress=zstd,noatime LABEL=archpool /mnt/var/log
mount "$EFI_PART" /mnt/boot

pacstrap -K /mnt base linux-zen linux-zen-headers linux-firmware btrfs-progs networkmanager

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "$HOSTNAME" > /etc/hostname

useradd -m -G wheel $USERNAME
# Set passwords for root and the created user
echo "root:${ROOT_PASS}" | chpasswd
echo "${USERNAME}:${USER_PASS}" | chpasswd

sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

bootctl install

UUID=$(blkid -s UUID -o value "$ROOT_PART")

cat > /boot/loader/entries/arch-zen.conf <<BOOT
title Arch Linux (Zen)
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
options root=UUID=$UUID rootflags=subvol=@root rw
BOOT

cat > /boot/loader/loader.conf <<LOADER
default arch-zen
timeout 3
LOADER

systemctl enable NetworkManager

echo "KEYMAP=us" > /etc/vconsole.conf

mkinitcpio -P
EOF

echo "Installation complete. You can reboot now."
