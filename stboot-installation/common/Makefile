ROOTDIR := $(CURDIR)
COMMONDIR := $(ROOTDIR)/stboot-installation/common
CONFIGDIR := $(ROOTDIR)/cache/stboot-installation/

$(CONFIGDIR):
	@echo generating $@
	mkdir -p $(CONFIGDIR)

$(CONFIGDIR)/security_config.json.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	@echo "generating: $@ " 
	$(eval CONFIGS_NAMES := ST_BOOT_COMMON_ROOTCERT_FINGERPRINT_FILE|ST_BOOT_COMMON_NUM_SIGNATURES|ST_BOOT_COMMON_BOOT_MODE)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

$(ROOTDIR)/out/stboot-installation/security_configuration.json: $(CONFIGDIR)/security_config.json.conf
	@echo "\ngenerating: >$@" 
	$(COMMONDIR)/build_security_config.sh






$(CONFIGDIR)/initramfs-linuxboot.cpio.gz.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "generating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_MBR_KERNEL_VERSION)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

initramfs-linuxboot.cpio.gz: $(CONFIGDIR)/initramfs-linuxboot.cpio.gz.conf $(ROOTDIR)/stboot-installation/initramfs-includes/https_roots.pem security_configuration.json
	@echo "common/build_kernel.sh"





$(CONFIGDIR)/linuxboot.vmlinux.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "generating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_MBR_KERNEL_VERSION)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

linuxboot.vmlinux: linuxboot.vmlinux.conf
	@echo "linuxboot.vmlinux"




$(CONFIGDIR)/host_configuration.json.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "generating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_COMMON_NETWORK_HOST|ST_BOOT_COMMON_PROVISIONING_SERVER_URL)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

host_configuration.json: $(CONFIGDIR)/host_configuration.json.conf
	@echo "\ngenerating: $@" 
	build_host_config.sh






$(CONFIGDIR)/data_partition.ext4.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "generating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_COMMON_DATA_PARTITION_SIZE)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

# TODO extra targets to detect changes in folder
ASSET_MAIN = $(ROOTDIR)/out/os-packages/
ASSET_DIRS = $(shell find $(ASSET_MAIN) -type d)
ASSET_FILES = $(shell find $(ASSET_MAIN) -type f -name '*')

data_partition.ext4: data_partition.ext4.conf $(ASSET_MAIN) $(ASSET_DIRS) $(ASSET_FILES)
	@echo "\ngenerating: $@" 
	$(ROOTDIR)/stboot-installation/common/build_data_filesystem.sh






syslinux.cfg:
	@echo "\ngenerating: $@" 
	build_syslinux_config.sh






boot_partition.vfat: syslinux.cfg host_configuration.json ${CACHE}/syslinux linuxboot.vmlinux
	@echo "\ngenerating: $@" 
	$(ROOTDIR)/stboot-installation/mbr_bootloader/build_build_filesystem.sh



