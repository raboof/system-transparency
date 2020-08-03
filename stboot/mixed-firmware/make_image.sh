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
mmd -i "${img}".vfat ::boot/grub/i386-pc
mmd -i "${img}".vfat ::boot/grub/themes
mmd -i "${img}".vfat ::boot/grub/themes/starfield
mmd -i "${img}".vfat ::boot/grub/fonts

mkdir -p "${src}/grub2"
echo "configfile (hd0,msdos1)/boot/grub/grub.cfg" > "${src}/grub2/grub-early.cfg"
#echo "(hd0) /dev/loop0" > "${src}/grub2/device.map"
#echo "(hostdisk/dev/loop0) ${img}.vfat" >> "${src}/grub2/device.map"
echo "
insmod gettext
insmod font
insmod fat
insmod part_gpt
insmod part_msdos

if [ \"\${grub_platform}\" == \"efi\" ]; then
	insmod efi_gop
	insmod efi_uga
fi

if [ \"\${grub_platform}\" == \"pc\" ]; then
	insmod vbe
	insmod vga
fi

if loadfont \${prefix}/fonts/unicode.pf2
then
    insmod gfxterm
    set gfxmode=auto
    set gfxpayload=keep
    terminal_output console
fi

insmod normal

set default='0'
set timeout='3'
set root='(h0,1)'

menuentry \"STBOOT\" {
	linux /boot/${lnxbt_kernel}
	initrd /boot/${lnxbt_initramfs}
}" > "${src}/grub2/grub.cfg"

"${src}/bin/grub-mkimage" -O i386-pc -c "${src}/grub2/grub-early.cfg" -o "${src}/grub2/core.img" -p '(hd0,msdos1)/boot/grub' fat biosdisk boot chain configfile ext2 linux ls part_msdos reboot serial vga gettext terminal

for f in "${src}/lib/grub/i386-pc"/*.mod; do
	mcopy -i "${img}".vfat "${f}" ::boot/grub/i386-pc/
done
for f in "${src}/lib/grub/i386-pc"/*.o; do
        mcopy -i "${img}".vfat "${f}" ::boot/grub/i386-pc/
done
for f in "${src}/lib/grub/i386-pc"/*.lst; do
        mcopy -i "${img}".vfat "${f}" ::boot/grub/i386-pc/
done
for f in "${src}/lib/grub/i386-pc"/*.sh; do
        mcopy -i "${img}".vfat "${f}" ::boot/grub/i386-pc/
done
for f in "${src}/share/grub/themes/starfield"/*; do
        mcopy -i "${img}".vfat "${f}" ::boot/grub/themes/starfield/
done
# Method2: Put core.img in filesystem and point to it.
#mcopy -i "${img}".vfat "${src}/grub2/core.img" ::boot/grub/i386-pc/core.img
#grub_offset=$(LANG=C grep --max-count=1 --only-matching --byte-offset --binary --text --perl-regexp "\x52\x56\xbe\x63\x81\xe8\x8a\x01" "${img}".vfat|cut -d: -f1)

mcopy -i "${img}".vfat "${src}/grub2/grub.cfg" ::boot/grub/grub.cfg
mcopy -i "${img}".vfat "${src}/share/grub/unicode.pf2" ::boot/grub/fonts/unicode.pf2

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
#parted -s --align optimal "${img}" mklabel gpt mkpart "STBOOT" fat32 "$((offset_vfat * 512))B" "$((offset_vfat * 512 + size_vfat))B" mkpart "STDATA" ext4 "$((offset_ext4 * 512))B" "$((offset_ext4 * 512 + size_ext4))B" set 1 boot on set 1 legacy_boot on
parted -s --align optimal "${img}" mklabel msdos mkpart primary fat32 "$((offset_vfat * 512))B" "$((offset_vfat * 512 + size_vfat))B" mkpart primary ext4 "$((offset_ext4 * 512))B" "$((offset_ext4 * 512 + size_ext4))B" set 1 boot on

echo ""
echo "[INFO]: Installing MBR"
dd bs=440 count=1 conv=notrunc if="${src}/grub2/boot.img" of="${img}" status=none
# Set GRUB_BOOT_MACHINE_BOOT_DRIVE to 0xff
echo -n -e '\xFF'| dd of="${img}" seek=$((0x64)) count=1 bs=1 conv=notrunc

dd if="${src}/grub2/core.img" of="${img}" bs=512 seek=2 conv=notrunc status=none
grub_offset=1024

# Set GRUB_BOOT_MACHINE_KERNEL_SECTOR to offset_vat + grub_offset/512
n=$((${grub_offset}/512))
echo "GRUB2 core.img is at ${grub_offset} sector $n"
for i in 0 1 2 3 4 5 6 7; do
	printf \\$(printf '%03o' $((($n >> ($i * 8)) & 0xff))) | dd of="${img}" seek=$((0x5c + $i)) count=1 bs=1 conv=notrunc status=none
done

echo ""
echo "[INFO]: Image layout:"
parted -s "${img}" print

echo ""
echo "[INFO]: $(realpath --relative-to=${root} ${img}) created."
