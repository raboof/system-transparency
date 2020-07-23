#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

failed="\e[1;5;31mfailed\e[0m"

# Set magic variables for current file & dir
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "${dir}/../../" && pwd)"

img="${dir}/STBoot_mixed_firmware.img"
img_backup="${dir}/STBoot_mixed_firmware.img.backup"
part_table="${dir}/gpt.table"
lnxbt_kernel="${dir}/vmlinuz-linuxboot"
lnxbt_initramfs="${root}/stboot/initramfs-linuxboot.cpio.gz"
src="${root}/cache/trusted_grub/install/"
mnt=$(mktemp -d -t stmnt-XXXXXXXX)

if [ -f "${img}" ]; then
    while true; do
        echo "Current image file:"
        ls -l "$(realpath --relative-to=${root} ${img})"
        read -rp "Rebuild image? (y/n)" yn
        case $yn in
            [Yy]* ) echo "[INFO]: backup existing image to $(realpath --relative-to=${root} ${img_backup})"; mv "${img}" "${img_backup}"; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
   done
fi

echo "[INFO]: check for Linuxboot initramfs including stboot bootloader"
bash "${root}/stboot/make_initramfs.sh"

echo "[INFO]: check for Linuxboot kernel"
bash "${dir}/make_kernel.sh"

echo "[INFO]: Building trusted grub"
bash "${root}/stboot/make_trusted_grub.sh"

echo "Linuxboot kernel: $(realpath --relative-to="${root}" "${lnxbt_kernel}")"
echo "Linuxboot initramfs: $(realpath --relative-to="${root}" "${lnxbt_initramfs}")"

echo "[INFO]: Creating filesystems:"

size_vfat=$((32*(1<<20)))
alignment=1048576

# mkfs.vfat requires size as an (undefined) block-count; seem to be units of 1k
if [ -f "${img}".vfat ]; then rm "${img}".vfat; fi
mkfs.vfat -C -n "STBOOT" "${img}".vfat $((size_vfat >> 10))

echo "[INFO]: Installing Trusted Grub"
mmd -i "${img}".vfat ::boot
mmd -i "${img}".vfat ::boot/grub

mkdir -p "${src}/grub2"
echo "configfile (hd0,msdos1)/boot/grub/grub.cfg" > "${src}/grub2/grub-early.cfg"
echo "(hd0) /dev/loop0" > "${src}/grub2/device.map"
echo "(hostdisk/dev/loop0) ${img}.vfat" >> "${src}/grub2/device.map"
echo "
insmod ext2
insmod gettext

set default='0'
set timeout='3'
set root='(h0,1)'

menuentry \"STBOOT\" {
	linux /boot/${lnxbt_kernel}
   initrd /boot/${lnxbt_initramfs}
}" > "${src}/grub2/grub.cfg"

"${src}/bin/grub-mkimage" -O i386-pc -c "${src}/grub2/grub-early.cfg" -o "${src}/grub2/core.img" -p '(hd0,msdos1)/boot/grub' biosdisk boot chain configfile ext2 linux ls part_msdos reboot serial vga gettext

cp "${src}/lib/grub/i386-pc"/*.img "${src}/grub2/"
mcopy -i "${img}".vfat "${src}/grub2/core.img" ::boot/grub/grub
mcopy -i "${img}".vfat "${src}/grub2/grub.cfg" ::boot/grub/grub.cfg

echo "[INFO]: Moving linuxboot kernel and initramfs to image"
mcopy -i "${img}".vfat "${lnxbt_kernel}" ::
mcopy -i "${img}".vfat "${lnxbt_initramfs}" ::

size_ext4=$((747*(1<<20)))

if [ -f "${img}".ext4 ]; then rm "${img}".ext4; fi
mkfs.ext4 -L "STDATA" "${img}".ext4 $((size_ext4 >> 10))

echo "[INFO]: Moving data files to image"
ls -l "${root}/stboot/data/."

e2mkdir "${img}".ext4:/etc
e2mkdir "${img}".ext4:/stboot
e2mkdir "${img}".ext4:/stboot/etc
e2mkdir "${img}".ext4:/stboot/bootballs
e2mkdir "${img}".ext4:/stboot/bootballs/new
e2mkdir "${img}".ext4:/stboot/bootballs/invalid
e2mkdir "${img}".ext4:/stboot/bootballs/known_good

for i in "${root}/stboot/data"/*; do
  [ -e "$i" ] || continue
  e2cp "$i" "${img}".ext4:/stboot/etc
done

e2ls "${img}".ext4:/stboot/etc/

echo "[INFO]: Moving bootballs to image (for LocalStorage bootmode)"
ls -l "${root}/bootballs/."
for i in "${root}/bootballs"/*; do
  [ -e "$i" ] || continue
  e2cp "$i" "${img}".ext4:/stboot/bootballs/new
done

echo "[INFO]: Constructing harddisk image from generated filesystems:"

offset_vfat=$(( alignment/512 ))
offset_ext4=$(( (alignment + size_vfat + alignment)/512 ))

# insert the filesystem to a new file at offset 1MB
dd if="${img}".vfat of="${img}" conv=notrunc obs=512 status=none seek=${offset_vfat}
dd if="${img}".ext4 of="${img}" conv=notrunc obs=512 status=none seek=${offset_ext4}

# extend the file by 1MB
truncate -s "+${alignment}" "${img}"

# Cleanup
rm "${img}".vfat
rm "${img}".ext4

echo "[INFO]: Adding partitions to harddisk image:"

# apply partitioning
parted -s --align optimal "${img}" mklabel gpt mkpart "STBOOT" fat32 "$((offset_vfat * 512))B" "$((offset_vfat * 512 + size_vfat))B" mkpart "STDATA" ext4 "$((offset_ext4 * 512))B" "$((offset_ext4 * 512 + size_ext4))B" set 1 boot on set 1 legacy_boot on

echo ""
echo "[INFO]: Installing MBR"
dd bs=440 count=1 conv=notrunc if="${src}/grub2/boot.img" of="${img}" status=none

echo ""
echo "[INFO]: Image layout:"
parted -s "${img}" print

echo ""
echo "[INFO]: $(realpath --relative-to=${root} ${img}) created."
