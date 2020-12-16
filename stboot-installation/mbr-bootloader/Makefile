.PHONY: all

ROOTDIR := $(CURDIR)
COMMONDIR := $(ROOTDIR)/stboot-installation/common
CONFIGDIR := $(ROOTDIR)/cache/stboot-installation/





stboot_mbr_installation.img: boot_partition.vfat data_partition.ext4
	@echo "\ngenerating: :@"
	$(ROOTDIR)/stboot-installation/mbr_bootloader/build_image.sh





$(CONFIGDIR)/st_boot_mbr_kernel_config.patch.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "generating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_MBR_KERNEL_CONFIG|ST_BOOT_LINUXBOOT_CMDLINE)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

st_boot_mbr_kernel_config.patch: $(CONFIGDIR)/st_boot_mbr_kernel_config.patch.conf
	@echo "\ngenerating: $@" 
	build_mbr_kernel_config.sh




all: linuxboot.vmlinux.conf $(ROOTDIR)/out/stboot-installation/security_configuration.json
	@echo "all" 	
