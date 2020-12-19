.PHONY: all


ROOTDIR := $(CURDIR)
COMMONDIR := $(ROOTDIR)/stboot-installation/common
CONFIGDIR := $(ROOTDIR)/cache/stboot-installation/
OUTDIR := $(ROOTDIR)/out/stboot-installation


include ./stboot-installation/common/Makefile



stboot_efi_installation.img: boot_partition.vfat data_partition.ext4
	@echo "\ngenerating: :@"
	$(ROOTDIR)/stboot-installation/efi-application/build_image.sh





$(CONFIGDIR)/st_boot_efi_kernel_config.patch.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "generating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_EFI_KERNEL_CONFIG|ST_BOOT_LINUXBOOT_CMDLINE)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

st_boot_efi_kernel_config: $(CONFIGDIR)/st_boot_efi_kernel_config.conf
	@echo "\ngenerating: $@" 
	build_efi_kernel_config.sh




all: stboot_efi_installation.img
	@echo "all" 	
