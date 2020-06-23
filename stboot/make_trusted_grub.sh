#! /bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

failed="\e[1;5;31mfailed\e[0m"

# Set magic variables for current file & dir
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "${dir}/../" && pwd)"

# ---

# Define constants

trusted_grub_archive_url="https://github.com/system-transparency/TrustedGRUB2/archive/1.4.1.tar.gz"
trusted_grub_archive_file_name="trusted_grub.tar.gz"
trusted_grub_src_dir_name="TrustedGRUB2-1.4.1"
trusted_grub_archive_checksum_file="tg_checksum"

trusted_grub_install_dir_name="install"

cache_dir="${root}/cache/trusted_grub"

trusted_grub_install_dir="${cache_dir}/${trusted_grub_src_dir_name}/${trusted_grub_install_dir_name}"
trusted_grub_bin="${trusted_grub_install_dir}/sbin/grub-install"

function info {
  echo "[INFO]" $1
}

function createCacheDir {
  mkdir -p "${cache_dir}"
}

# Download and verify the TrustedGRUB2 sources
function downloadTrustedGrub {
  createCacheDir

  info "Downloading TrustedGRUB2 sources..."
  wget "${trusted_grub_archive_url}" -O "${cache_dir}/${trusted_grub_archive_file_name}"

  info "Verifying TrustedGRUB2 source integrity..."
  cp "${dir}/${trusted_grub_archive_checksum_file}" "${cache_dir}/${trusted_grub_archive_checksum_file}"

  cd "${cache_dir}"
  shasum -a 256 -b -c "${trusted_grub_archive_checksum_file}"
  cd "${dir}"
}

# Build TrustedGRUB2 from source...
function buildTrustedGrub {
  info "Unpacking sources..."
  tar -xf "${cache_dir}/${trusted_grub_archive_file_name}" -C "${cache_dir}"

  cd "${cache_dir}/${trusted_grub_src_dir_name}"

  mkdir "${trusted_grub_install_dir_name}"

  info "Running configuration..."
  ./autogen.sh
  ./configure --prefix="${trusted_grub_install_dir}" --disable-werror --target=i386 -with-platform=pc

  info "Building..."
  make
  make install

  info "Cleaning up..."
  make clean

  info "Saved the grub-install binary to"
  info "${trusted_grub_bin}"

  cd "${dir}"
}

downloadTrustedGrub

buildTrustedGrub
