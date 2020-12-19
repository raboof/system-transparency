.PHONY: all

ROOTDIR := $(CURDIR)
COMMONDIR := $(ROOTDIR)/stboot-installation/common
CONFIGDIR := $(ROOTDIR)/cache/stboot-installation
OUTDIR := $(ROOTDIR)/out/stboot-installation

include ./stboot-installation/common/Makefile


$(OUTDIR)/mbr-bootloader/stboot_mbr_installation.img: $(OUTDIR)/boot_partition.vfat $(OUTDIR)/data_partition.ext4
	@echo "\ngenerating: :@"
	$(ROOTDIR)/stboot-installation/mbr_bootloader/build_image.sh





$(CONFIGDIR)/st_boot_mbr_kernel.config.conf: $(ROOTDIR)/run.config $(CONFIGDIR)
	@echo "\ngenerating: $@ "
	$(eval CONFIGS_NAMES := ST_BOOT_MBR_KERNEL_CONFIG|ST_BOOT_LINUXBOOT_CMDLINE)
	cat $(ROOTDIR)/run.config | grep -E "$(CONFIGS_NAMES)" >> $@.temp
	rsync -c $@.temp $@
	rm $@.temp

$(OUTDIR)/st_boot_mbr_kernel.config: "$(CONFIGDIR)/st_boot_mbr_kernel.config.conf"
	@echo "\ngenerating: $@" 
	build_mbr_kernel_config.sh




all: $(OUTDIR)/mbr-bootloader/stboot_mbr_installation.img
	@echo "all" 	
