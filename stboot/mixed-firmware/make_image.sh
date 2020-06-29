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
src="${root}/cache/syslinux/"
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

echo "[INFO]: check for Linuxboot kernel"
bash "${dir}/make_kernel.sh"

echo "[INFO]: check for Linuxboot initramfs including stboot bootloader"
bash "${root}/stboot/make_initramfs.sh"

trusted_grub_bin="${root}/cache/trusted_grub/grub-install"
if [ ! -f "${trusted_grub_bin}" ]; then
   echo "[INFO]: build TrustedGRUB2"
   bash "${root}/stboot/make_trusted_grub.sh"
fi


echo "Linuxboot kernel: $(realpath --relative-to=${root} ${lnxbt_kernel})"
echo "Linuxboot initramfs: $(realpath --relative-to=${root} ${lnxbt_initramfs})"


echo "[INFO]: Creating raw image"
dd if=/dev/zero "of=${img}" bs=1M count=500
sudo losetup -f || { echo -e "Finding free loop device $failed"; exit 1; }
dev=$(sudo losetup -f)
sudo losetup "${dev}" "${img}" || { echo -e "Loop device setup $failed"; sudo losetup -d "${dev}"; exit 1; }
sudo sfdisk --no-reread --no-tell-kernel "${dev}" < "${part_table}" || { echo -e "partitioning $failed"; sudo losetup -d "${dev}"; exit 1; }
sudo partprobe -s "${dev}" || { echo -e "partprobe $failed"; sudo losetup -d "${dev}"; exit 1; }
echo "[INFO]: Make VFAT filesystem for boot partition"
sudo mkfs -t vfat "${dev}p1" || { echo -e "Creating filesystem on 1st partition $failed"; sudo losetup -d "${dev}"; exit 1; }
echo "[INFO]: Make EXT4 filesystem for data partition"
sudo mkfs -t ext4 "${dev}p2" || { echo -e "Creating filesystem on 2nd psrtition $failed"; sudo losetup -d "${dev}"; exit 1; }
sudo partprobe -s "${dev}" || { echo -e "partprobe $failed"; sudo losetup -d "${dev}"; exit 1; }
echo "[INFO]: Image layout:"
lsblk -o NAME,SIZE,TYPE,PTTYPE,PARTUUID,PARTLABEL,FSTYPE ${dev}

echo ""
echo "[INFO]: Installing TrustedGRUB"
sudo mount "${dev}p1" "${mnt}" || { echo -e "Mounting ${dev}p1 $failed"; sudo losetup -d "${dev}"; exit 1; }
sudo mkdir -p "${mnt}/boot/grub" || { echo -e "Making grub config directory $failed"; sudo losetup -d "${dev}"; exit 1; }
sudo "${trusted_grub_bin}" "--target=i386-pc" "--root-directory=${mnt}/" "${dev}" || { echo -e "Writing volume boot record $failed"; sudo losetup -d "${dev}"; exit 1; }

echo ""
echo "[INFO]: Moving linuxboot kernel and initramfs to image"
sudo cp ${lnxbt_kernel} ${mnt}
sudo cp ${lnxbt_initramfs} ${mnt}
sudo umount "${mnt}" || { echo -e "Unmounting $failed"; sudo losetup -d "$dev"; exit 1; }

echo ""
echo "[INFO]: Moving data files to image"
ls -l "${root}/stboot/data/."
sudo mount "${dev}p2" "${mnt}" || { echo -e "Mounting ${dev}p2 $failed"; sudo losetup -d "$dev"; exit 1; }
sudo cp -R "${root}/stboot/data/." "${mnt}"
sudo umount "${mnt}" || { echo -e "Unmounting $failed"; sudo losetup -d "$dev"; exit 1; }

sudo losetup -d "${dev}"
rm -r -f "${mnt}"

echo ""
echo "[INFO]: $(realpath --relative-to=${root} ${img}) created."
