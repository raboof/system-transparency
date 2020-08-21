home = /home/riot

gobin = /go/bin
gosrc = /go/src

uroot_src = /github.com/u-root/u-root
uroot_tools = /tools
uroot_pkg = /pkg

stboot = /boot/stboot

cpu_repo = github.com/u-root/cpu
strepo = ${PWD}/..

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
ifeq (,$(wildcard ./../run.config))
	make ${strepo}/bootballs

	./make_global_config.sh
include ./../run.config
else
include ./../run.config
endif
		
	
	
${strepo}/bootballs : 
	mkdir ./../bootballs

geturoot :
	go get -v github.com/u-root/u-root

toolchain :
	@echo Creating toolchain ;
	make run.config 
ifeq (,$(wildcard ${home}${gosrc}${uroot_src}))
make geturoot
endif
	git -C ${home}${gosrc}${uroot_src} checkout --quiet stboot 
	make ~${gobin}/u-root 
	make ~${gobin}/stmanager 
	make cpu 

~${gobin}/u-root : ${uroot_dep}
	@echo Install u-root ;
	go install ${home}${gosrc}${uroot_src} 
	
~${gobin}/stmanager : ${stmanagerg_dep}
	@echo Install STManager ;
	go install ${home}${gosrc}${uroot_src}${uroot_tools}/stmanager

cpu : 
	@echo Get cpu module ;
	go get -v ${cpu_repo}/cmds/cpu ${cpu_repo}/cmds/cpud


keys : ./../keys/signing_keys ./../keys/cpu_keys
	@echo Key generation ;
	openssl genrsa -f4 -out 
