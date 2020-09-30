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
#FIXME: add cleaner way to specify key locations, optimize the code
	openssl genrsa -f4 -out ".key" 4096
	@echo self-signing root certificate
	openssl req -new -key ".key" -batch -subj '/CN=Test Root CA' -out "{}/root.cert" -x509 -days 1024
	@echo creating rootcertificate fingerprint
	
	@echo generate keys for the cpu command
	ssh-keygen -b 2048 -t rsa -f "${}/ssh_host_rsa_key" -q -N "" <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f "${}/cpu_rsa" -q -N "" <<< y >/dev/null

bootball:
	make run.config
	
~${gobin}/u-root : ${uroot_dep}
	@echo Install u-root ;
	go install ${home}${gosrc}${uroot_src} 
	
~${gobin}/stmanager : ${stmanagerg_dep}
	@echo Install StManager ;
	go install ${home}${gosrc}${uroot_src}${uroot_tools}/stmanager



.PHONY: 
