#! /bin/bash


# generate folder for our scriptoutout
mkdir -p ./cache/configs/generated
# folder to detect changed files
# both folders sync in later steps and only changes get applied. 
mkdir -p ./cache/configs/current


# divide config to corresponding configfiles
file=st_boot_efi.conf
array=(\
"ST_BOOT_EFI" \
"ST_BOOT_COMMON_LINUXBOOT" \
"ST_BOOT_COMMON_NETWORK" \
"ST_BOOT_COMMON_PROVISIONING_SERVER_URL" \
"ST_BOOT_COMMON_DATA_PARTITION_SIZE" \
"ST_BOOT_COMMON_CUSTOMIZE_KERNEL_CONFIG" \
"ST_BOOT_COMMON_BOOT_MODE" \
"ST_BOOT_COMMON_NUM_SIGNATURES" \
"ST_BOOT_COMMON_ROOTCERT_FINGERPRINT_FILE")

rm -f ./cache/configs/generated/$file
for i in "${array[@]}"; do   # The quotes are necessary here
    cat run.config | grep "^$i" >>  ./cache/configs/generated/$file
done


file=st_boot_mbr.conf
array=(\
"ST_BOOT_MBR" \
"ST_BOOT_COMMON_LINUXBOOT" \
"ST_BOOT_COMMON_NETWORK" \
"ST_BOOT_COMMON_PROVISIONING_SERVER_URL" \
"ST_BOOT_COMMON_DATA_PARTITION_SIZE" \
"ST_BOOT_COMMON_CUSTOMIZE_KERNEL_CONFIG" \
"ST_BOOT_COMMON_BOOT_MODE" \
"ST_BOOT_COMMON_NUM_SIGNATURES" \
"ST_BOOT_COMMON_ROOTCERT_FINGERPRINT_FILE")

rm -f ./cache/configs/generated/$file
for i in "${array[@]}"; do   # The quotes are necessary here
    cat run.config | grep "^$i" >>  ./cache/configs/generated/$file
done

file=st_boot_coreboot.conf
array=(\
"ST_BOOT_COMMON_NETWORK" \
"ST_BOOT_COMMON_PROVISIONING_SERVER_URL" \
"ST_BOOT_COMMON_DATA_PARTITION_SIZE")

rm -f ./cache/configs/generated/$file
for i in "${array[@]}"; do   # The quotes are necessary here
    cat run.config | grep "^$i" >>  ./cache/configs/generated/$file
done

# sync files to newer folder
# "-c" means test if checksum changed. if not dont sync it.
# timestamp only changes if the file changes. (Makefiles check only timestamps)  
rsync -acv ./cache/configs/generated/ ./cache/configs/current/
