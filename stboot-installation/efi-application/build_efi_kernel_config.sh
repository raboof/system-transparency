#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "${dir}/../../" && pwd)"

# import global configuration
source ${root}/run.config

common="${root}/stboot-installation/common"
kernel_out="${root}/out/stboot-installation/efi-application/linuxboot.efi"
kernel_version=${ST_BOOT_EFI_KERNEL_VERSION}
kernel_config=${ST_BOOT_EFI_KERNEL_CONFIG}
cmdline=${ST_BOOT_COMMON_LINUXBOOT_CMDLINE}

echo
echo "[INFO]: Patching kernel configuration to include configured command line:"
echo "cmdline: ${cmdline}"
cp "${kernel_config}" "${kernel_config}.patch"
sed -i "s/CONFIG_CMDLINE=.*/CONFIG_CMDLINE=\"${cmdline}\"/" "${kernel_config}.patch"