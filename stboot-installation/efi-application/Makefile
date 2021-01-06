.PHONY: all


ROOTDIR := $(CURDIR)
COMMONDIR := $(ROOTDIR)/stboot-installation/common
EFIDIR := $(ROOTDIR)/stboot-installation/efi-application
CONFIGDIR := $(ROOTDIR)/cache/stboot-installation/
OUTDIR := $(ROOTDIR)/out/stboot-installation


include ./stboot-installation/common/Makefile



$(OUTDIR)/efi-application/stboot_efi_installation.img: $(OUTDIR)/efi-application/boot_partition.vfat $(OUTDIR)/data_partition.ext4
	@echo "\ngenerating: :@"
	$(ROOTDIR)/stboot-installation/efi-application/build_image.sh





$(CONFIGDIR)/st_boot_efi_kernel.config.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	echo "\ngenerating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_EFI_KERNEL_CONFIG|ST_BOOT_COMMON_LINUXBOOT_CMDLINE)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

$(OUTDIR)/st_boot_efi_kernel.config: $(CONFIGDIR)/st_boot_efi_kernel.config.conf
	@echo "\ngenerating: $@" 
	$(EFIDIR)/build_efi_kernel_config.sh






$(OUTDIR)/efi-application/boot_partition.vfat: $(OUTDIR)/host_configuration.json $(OUTDIR)/efi-application/linuxboot.efi
	@echo "\ngenerating: $@" 
	$(EFIDIR)/build_boot_filesystem.sh









all: $(OUTDIR)/efi-application/stboot_efi_installation.img
	@echo "all" 	
