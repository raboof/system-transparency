.PHONY: mbr_bootloader efi_application

mbr_bootloader: 
	@echo generating MBR BOOTLOADER
	$(MAKE) -f ./stboot-installation/mbr-bootloader/Makefile


efi_application:
	@echo generating EFI APPLICATION 
	$(MAKE) -f ./stboot-installation/efi-application/Makefile 


