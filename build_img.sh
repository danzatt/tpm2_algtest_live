#!/bin/sh

set -ex

OUT_IMG=algtest-usb-disk.img
PERSISTENT_PART_MiB=600
PERSISTENT_PART_NAME="ALGTEST_RES"

iso_path=$1
version=$2

iso_size=$(du -b $iso_path | cut -f 1)
img_size=$(( $iso_size + (300 << 20) )) # add 100 MiB

#round to blocksize
img_size=$(( (($img_size >> 9) << 9) + 512))

echo $img_size

#dd if=/dev/zero of=$OUT_IMG skip=$img_size bs=1 count=0
dd if=/dev/zero of=$OUT_IMG seek=$img_size bs=1 count=0

lodev=$(losetup --show -fP $OUT_IMG)
yes | livecd-iso-to-disk --label ALGTST_LIVE --format --efi --reset-mbr --noverify --force $iso_path $lodev

boot_part_end=$(gdisk -l $OUT_IMG | grep EF00 | sed -e 's/^[ ]*\([0-9]\+\)[ ]*\([0-9]\+\)[ ]*\([0-9]\+\).*/\3/g')

losetup -d $lodev

# partition created by livecd-iso-to-disk fills the whole device so we append new space
dd oflag=append conv=notrunc if=/dev/zero of=$OUT_IMG bs=1MiB count=$PERSISTENT_PART_MiB

# increase GPT size to fill the device
sgdisk $OUT_IMG -e

sgdisk --largest-new=0 $OUT_IMG --typecode=0700

lodev=$(losetup --show -fP $OUT_IMG)
kpartx $lodev
mkfs.vfat -F32 -n $PERSISTENT_PART_NAME ${lodev}p4

mkdir mnt
mount ${lodev}p1 mnt
UUID=$(grep -e 'UUID=[^ ]*' mnt/EFI/BOOT/grub.cfg -m 1 -o | cut -c6-)

cat > mnt/EFI/BOOT/grub.cfg << EOF
set default="0"

function load_video {
  insmod efi_gop
  insmod efi_uga
  insmod video_bochs
  insmod video_cirrus
  insmod all_video
}

load_video
set gfxpayload=keep
insmod gzio
insmod part_gpt
insmod ext2

set timeout=60
### END /etc/grub.d/00_header ###

search --no-floppy --set=root -l 'Fedora-algtest-${version}'

### BEGIN /etc/grub.d/10_linux ###
menuentry 'Start Fedora-algtest-Live ${version}' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /syslinux/vmlinuz root=live:UUID=$UUID rd.live.image rw
	initrdefi /syslinux/initrd.img
}
menuentry 'Test this media & start Fedora-algtest-Live ${version}' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /syslinux/vmlinuz root=live:UUID=$UUID rd.live.image rw rd.live.check
	initrdefi /syslinux/initrd.img
}
menuentry 'Start Fedora-algtest-Live ${version} in text mode' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /syslinux/vmlinuz root=live:UUID=$UUID rd.live.image rw 4
	initrdefi /syslinux/initrd.img
}
submenu 'Troubleshooting -->' {
	menuentry 'Start Fedora-algtest-Live ${version} in basic graphics mode' --class fedora --class gnu-linux --class gnu --class os {
		linuxefi /syslinux/vmlinuz root=live:UUID=$UUID rd.live.image rw nomodeset
		initrdefi /syslinux/initrd.img
	}
}

EOF

sync
sync
sync

sleep 1

umount mnt
rmdir mnt
sfdisk --part-type $lodev 4 EBD0A0A2-B9E5-4433-87C0-68B6B72699C7
losetup -d $lodev
