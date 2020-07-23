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
trusted_grub_archive_checksum="039396e6fe22f474805b8644eac9a9539d5ab08b66f2d7d9da5f9f7b33a159a7"

cache_dir="${root}/cache/trusted_grub"

trusted_grub_install_dir="${cache_dir}/install/"

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
  echo "${trusted_grub_archive_checksum} *./trusted_grub.tar.gz" > "${cache_dir}/tg_checksum"

  cd "${cache_dir}"
  shasum -a 256 -b -c "tg_checksum" || (rm "${cache_dir}/${trusted_grub_archive_file_name}" && exit 1)
  rm "tg_checksum"

  echo "${trusted_grub_archive_checksum}" > "${cache_dir}/checksum"
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
  make -j $(nproc)
  make install

  cd "${dir}"
}

download=0
if [ ! -f "${cache_dir}/${trusted_grub_src_dir_name}/autogen.sh" ]; then
  download=1
fi
if [ ! -f "${cache_dir}/${trusted_grub_archive_file_name}" ]; then
  download=1
fi
if [ "$(cat ${cache_dir}/checksum)" != "${trusted_grub_archive_checksum}" ]; then
  download=1
fi

build=download
if [ ! -f "${trusted_grub_install_dir}/sbin/grub-install" ]; then
  build=1
fi
if [ ! -f "${cache_dir}/${trusted_grub_src_dir_name}/configure" ]; then
  build=1
fi

if [ "${download}" == "1" ]; then
  downloadTrustedGrub
fi

if [ "${build}" == "1" ]; then
  buildTrustedGrub
fi
