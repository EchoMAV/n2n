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
PKGDEPS ?= host nmap tcpdump libssl-dev libpcap-dev
PYTHONPKGS=
SERVICES=edge.service

.PHONY = clean deps enable install provision see test uninstall update

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
	# NB: only needed when PKGDEPS, PYTHONPKGS is not empty
	@if [ ! -z "$(PKGDEPS)" ] ; then $(SUDO) apt-get install -y $(PKGDEPS) ; fi
	@if [ ! -z "$(PYTHONPKGS)" ] ; then $(SUDO) pip3 install $(PYTHONPKGS) ; fi

enable:
	@( for c in stop disable ; do $(SUDO) systemctl $${c} $(SERVICES) ; done ; true )
	@( for s in $(SERVICES) ; do $(SUDO) install -Dm644 $${s%.*}.service $(LIBSYSTEMD)/$${s%.*}.service ; done ; true )
	@if [ ! -z "$(SERVICES)" ] ; then $(SUDO) systemctl daemon-reload ; fi
	@( for s in $(SERVICES) ; do $(SUDO) systemctl enable $${s%.*} ; done ; true )

install: deps $(N2N)
	@$(MAKE) --no-print-directory $(EDGE)
	@$(MAKE) --no-print-directory enable

provision: $(CONFIG) $(N2N)
	@if [ -e $(CONFIG)/$(SN).mav ] ; then \
		$(SUDO) python3 configure.py --mavnet=$(CONFIG)/$(SN).mav --interactive ; \
	else \
		$(SUDO) python3 configure.py --interactive --start ; \
	fi

see:
	cat $(N2N)/edge.conf

test:
	@if [ -e $(N2N)/edge.conf ] ; then \
		DEV=$(shell grep ^-d $(N2N)/edge.conf | cut -f2 -d=) ; \
		ADR := $(shell ip -o -f inet addr show $$DEV | tr -s [:space:] | cut -s -f4 -d' ') ; \
		nmap -sP $$ADR ; \
	fi

uninstall:
	@( for c in stop disable ; do $(SUDO) systemctl $${c} $(SERVICES) ; done ; true )
	@( for s in $(SERVICES) ; do $(SUDO) rm $(LIBSYSTEMD)/$${s%.*}.service ; done ; true )
	@if [ ! -z "$(SERVICES)" ] ; then $(SUDO) systemctl daemon-reload ; fi
	$(SUDO) rm -f $(N2N)/.* && $(SUDO) rmdir $(N2N)

update:
	@cd src && git pull
