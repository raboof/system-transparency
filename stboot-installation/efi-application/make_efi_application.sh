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

bash "${common}/build_security_config.sh"

bash "${common}/build_initramfs.sh"

bash "${dir}/build_efi_kernel_config.sh"

bash "${common}/build_kernel.sh" "${root}/${kernel_config}" "${kernel_out}" "${kernel_version}"

bash "${common}/build_host_config.sh"

bash "${dir}/build_boot_filesystem.sh"

bash "${common}/build_data_filesystem.sh"

bash "${dir}/build_image.sh"

trap - EXIT