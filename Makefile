# TODO: Adopt u-root's go modules approach

home = /home/vaishali

gobin = ${go env GOPATH}/bin
gosrc = ${go env GOPATH}/src
uroot_branch=${ST_UROOT_DEV_BRANCH}
uroot_src = /github.com/u-root/u-root
uroot_tools = /tools
uroot_pkg = /pkg

stboot = /boot/stboot

cpu_src = github.com/u-root/cpu
stdir = ${PWD}/...

stmanagerg_dep = 	${home}${gosrc}${uroot_src}${uroot_tools}/stmanager/stmanager.go	\
					${home}${gosrc}${uroot_src}${uroot_tools}/stmanager/commands.go		\
					${home}${gosrc}${uroot_src}${uroot_pkg}${stboot}/bootball.go		\
					${home}${gosrc}${uroot_src}${uroot_pkg}${stboot}/signature.go		\
					${home}${gosrc}${uroot_src}${uroot_pkg}${stboot}/stboot.go			\
					${home}${gosrc}${uroot_src}${uroot_pkg}${stboot}/stconfig.go

uroot_dep = 		${home}${gosrc}${uroot_src}/u-root.go								\
					${home}${gosrc}${uroot_src}${uroot_pkg}/golang/build.go				\
					${home}${gosrc}${uroot_src}${uroot_pkg}/shlex/shlex.go				\
					${home}${gosrc}${uroot_src}${uroot_pkg}/uroot/uroot.go				\
					${home}${gosrc}${uroot_src}${uroot_pkg}/uroot/builder/bb.go			\
					${home}${gosrc}${uroot_src}${uroot_pkg}/uroot/builder/binary.go		\
					${home}${gosrc}${uroot_src}${uroot_pkg}/uroot/builder/source.go		\
					${home}${gosrc}${uroot_src}${uroot_pkg}/uroot/initramfs/archive.go	\
					${home}${gosrc}${uroot_src}${uroot_pkg}/uroot/initramfs/cpio.go		\
					${home}${gosrc}${uroot_src}${uroot_pkg}/uroot/initramfs/dir.go		\
					${home}${gosrc}${uroot_src}${uroot_pkg}/uroot/initramfs/files.go	\
					${home}${gosrc}${uroot_src}/Gopkg.lock

run.config :
	@echo Run config ;
# For now, create run.config manually via make_global_config.sh
# Replace it with make menuconfig like setup later on
ifeq (,$(wildcard ./run.config))
	./scripts/make_global_config.sh
include ./run.config
else
include ./run.config
endif

${strepo}/bootballs :
	mkdir ./../bootballs

geturoot :
	go get -v github.com/u-root/u-root
cpu :
	@echo get cpu module ;
	go get -v ${cpurepo}/cmds/cpu ${cpu_repo}/cmds/cpud
getacm :
	@echo get ACM grebber ;
	go get -u -v github.com/system-transparency/sinit-acm-grebber

toolchain :
	@echo creating a toolchain;
	make run.config
ifeq (,$(wildcard ${home}${gosrc}${uroot_src}))
	make geturoot
endif
	git -C ${home}${gosrc}${uroot_src} checkout --quiet ${uroot_branch} 
	make ~${gobin}/u-root 
	make ~${gobin}/stmanager 
	make cpu
	make sinit-acm-grebber

keys : ./../keys/signing_keys ./../keys/cpu_keys
	@echo Key generation ;
#FIXME: remove the bashscript way of doing things
	for I in 1 2 3 4 5
	do
		# Gen signing key
		openssl genrsa -f4 -out "${signing_key_dir}/signing-key-${I}.key" 4096
		# Certification request
		openssl req -new -key "${signing_key_dir}/signing-key-${I}.key" -batch  -subj '/CN=Signing Key '"${I}" -out "${signing_key_dir}/signing-key-${I}.req"
		# Fullfil certification req
		openssl x509 -req -in "${signing_key_dir}/signing-key-${I}.req" -CA "${signing_key_dir}/root.cert" -CAkey "${signing_key_dir}/root.key" -out "${signing_key_dir}/signing-key-${I}.cert" -days 365 -CAcreateserial
		# Remove certification req
		rm "${signing_key_dir}/signing-key-${I}.req"
	done

bootball:
	make run.config

~${gobin}/u-root : ${uroot_dep}
	@echo Install u-root ;
	go install ${home}${gosrc}${uroot_src} 

~${gobin}/stmanager : ${stmanagerg_dep}
	@echo Install StManager ;
	go install ${home}${gosrc}${uroot_src}${uroot_tools}/stmanager

.all: run.config toolchain
#.PHONY:
