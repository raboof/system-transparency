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

trusted_grub_archive_url="https://github.com/system-transparency/TrustedGRUB2/archive/stboot.tar.gz"
trusted_grub_archive_file_name="trusted_grub.tar.gz"
trusted_grub_src_dir_name="TrustedGRUB2-stboot"
trusted_grub_archive_checksum_file="tg_checksum"

cache_dir="${root}/cache/trusted_grub"

trusted_grub_install_dir=$1

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

  info "Running configuration..."
  ./autogen.sh
  ./configure --prefix="${trusted_grub_install_dir}" --disable-werror --target=i386 -with-platform=pc

  info "Building..."
  make
  make install

  info "Cleaning up..."
  rm -rf "${cache_dir}/${trusted_grub_archive_checksum_file}"
  rm -rf "${cache_dir}/${trusted_grub_archive_file_name}"

  cd "${dir}"
}

downloadTrustedGrub

buildTrustedGrub
