# Automation boilerplate

SHELL := /bin/bash
SN := $(shell hostname)
SUDO := $(shell test $${EUID} -ne 0 && echo "sudo")
.EXPORT_ALL_VARIABLES:


CONFIG ?= /var/local
EDGE=/usr/sbin/edge
LIBSYSTEMD=/lib/systemd/system
NTOP=https://github.com/ntop
N2N=/etc/n2n
PKGDEPS=host tcpdump libssl-dev libpcap-dev
PYTHONPKGS=
SERVICES_DISABLE=
SERVICES_ENABLE=edge.service
SERVICES=$(SERVICES_DISABLE) $(SERVICES_ENABLE)

.PHONY = clean deps install provision restore-services uninstall update

$(N2N): config
	@$(SUDO) mkdir -p $@
	@$(SUDO) cp config/* $@

$(EDGE): ./src
	@( cd ./src && ./autogen.sh && ./configure && make && $(SUDO) make install )

./src:
	@if [ ! -d $@ ] ; then git clone $(NTOP)/n2n.git -b dev src ; fi

clean:
	@if [ -d src ] ; then cd src && make clean ; fi

deps: src
	$(SUDO) apt-get update
	$(SUDO) apt-get install -y $(PKGDEPS)
	#$(SUDO) pip3 install ${PYTHONPKGS}

install: deps
	$(MAKE) --no-print-directory $(EDGE)
	$(MAKE) --no-print-directory restore-services

provision: $(CONFIG)
	$(SUDO) python3 configure.py --mavnet=$(CONFIG)/$(SN).mav

restore-services:
	@( for s in $(SERVICES) ; do $(SUDO) systemctl disable $$s ; done ; /bin/true )
	@( for s in $(SERVICES_ENABLE) ; do $(SUDO) install -Dm644 $$s $(LIBSYSTEMD)/$$s ; done ; /bin/true )
	$(SUDO) systemctl daemon-reload
	@( for s in $(SERVICES_ENABLE) ; $(SUDO) do systemctl enable $$s ; done ; /bin/true )

uninstall:
	@( for s in $(SERVICES) ; do $(SUDO) systemctl disable $$s ; done ; /bin/true )
	@( for s in $(SERVICES) ; do $(SUDO) rm -f $(LIBSYSTEMD)/$$s ; done ; /bin/true )
	$(SUDO) systemctl daemon-reload
	$(SUDO) rm -f $(N2N)/.* && $(SUDO) rmdir $(N2N)

update:
	@cd src && git pull

