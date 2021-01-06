ROOTDIR := $(CURDIR)
COMMONDIR := $(ROOTDIR)/stboot-installation/common
CONFIGDIR := $(ROOTDIR)/cache/stboot-installation
OUTDIR := $(ROOTDIR)/out/stboot-installation


$(CONFIGDIR)/security_configuration.json.conf: $(ROOTDIR)/run.config 
	@echo "\ngenerating: $@ " 
	$(eval CONFIGS_NAMES := ST_BOOT_COMMON_ROOTCERT_FINGERPRINT_FILE|ST_BOOT_COMMON_NUM_SIGNATURES|ST_BOOT_COMMON_BOOT_MODE)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

$(OUTDIR)/security_configuration.json: $(CONFIGDIR)/security_configuration.json.conf
	@echo "\ngenerating: $@" 
	$(COMMONDIR)/build_security_config.sh






$(CONFIGDIR)/initramfs-linuxboot.cpio.gz.conf: $(ROOTDIR)/run.config 
	echo "\ngenerating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_COMMON_LINUXBOOT_VARIANT)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp


# "KEYS" missing
$(OUTDIR)/initramfs-linuxboot.cpio.gz: $(CONFIGDIR)/initramfs-linuxboot.cpio.gz.conf $(ROOTDIR)/stboot-installation/initramfs-includes/https_roots.pem $(OUTDIR)/security_configuration.json
	@echo "\ngenerating: $@" 
	$(COMMONDIR)/build_initramfs.sh






$(CONFIGDIR)/initramfs-linuxboot.efi.conf: $(ROOTDIR)/run.config 
	echo "\ngenerating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_EFI_KERNEL_VERSION)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

$(OUTDIR)/efi-application/linuxboot.efi: $(CONFIGDIR)/initramfs-linuxboot.efi.conf $(OUTDIR)/st_boot_efi_kernel.config $(OUTDIR)/initramfs-linuxboot.cpio.gz
	@echo "\ngenerating: $@" 
	$(COMMONDIR)/build_kernel.sh






$(CONFIGDIR)/linuxboot.vmlinux.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "\ngenerating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_MBR_KERNEL_VERSION)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

$(OUTDIR)/mbr-bootloader/linuxboot.vmlinux: $(CONFIGDIR)/linuxboot.vmlinux.conf
	@echo "linuxboot.vmlinux"




$(CONFIGDIR)/host_configuration.json.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "\ngenerating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_COMMON_NETWORK_HOST|ST_BOOT_COMMON_NETWORK_MODE|ST_BOOT_COMMON_PROVISIONING_SERVER_URL)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

$(OUTDIR)/host_configuration.json: $(CONFIGDIR)/host_configuration.json.conf
	@echo "\ngenerating: $@" 
	$(COMMONDIR)/build_host_config.sh






$(CONFIGDIR)/data_partition.ext4.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "\ngenerating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_COMMON_DATA_PARTITION_SIZE)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

# TODO extra targets to detect changes in folder
ASSET_MAIN = $(ROOTDIR)/out/os-packages/
ASSET_DIRS = $(shell find $(ASSET_MAIN) -type d)
ASSET_FILES = $(shell find $(ASSET_MAIN) -type f -name '*')

$(OUTDIR)/data_partition.ext4: $(CONFIGDIR)/data_partition.ext4.conf $(ASSET_MAIN) $(ASSET_DIRS) $(ASSET_FILES)
	@echo "\ngenerating: $@" 
	$(ROOTDIR)/stboot-installation/common/build_data_filesystem.sh






$(OUTDIR)/mbr-bootloader/syslinux.cfg:
	@echo "\ngenerating: $@" 
	build_syslinux_config.sh






$(OUTDIR)/boot_partition.vfat: syslinux.cfg $(OUTDIR)/host_configuration.json ${CACHE}/syslinux $(OUTDIR)/mbr-bootloader/linuxboot.vmlinux
	@echo "\ngenerating: $@" 
	$(ROOTDIR)/stboot-installation/mbr_bootloader/build_build_filesystem.sh



