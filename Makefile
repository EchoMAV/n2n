# Automation boilerplate

SHELL := /bin/bash
SN := $(shell hostname)
SUDO := $(shell test $${EUID} -ne 0 && echo "sudo")
.EXPORT_ALL_VARIABLES:

CONFIG ?= /var/local
EDGE=/usr/sbin/edge
LIBSYSTEMD=/lib/systemd/system
N2N_REPO=https://github.com/ntop/n2n.git
N2N_REV=2.8
PKGDEPS ?= host nmap tcpdump libssl-dev libpcap-dev
PYTHONPKGS=
SERVICES=edge.service
SYSCFG=/etc/systemd

.PHONY = clean dependencies enable install provision see test uninstall update

default:
	@echo "Please choose an action:"
	@echo ""
	@echo "  dependencies: ensure all needed software is installed (requires internet)"
	@echo "  install: update programs and system scripts"
	@echo "  provision: interactively define the needed configurations (all of them)"
	@echo ""
	@echo "The above are issued in the order shown above.  dependencies is only done once."
	@echo ""

$(EDGE): ./src
	@( cd ./src && ./autogen.sh && ./configure && make && $(SUDO) make install )

./src:
	@if [ ! -d $@ ] ; then git clone $(N2N_REPO) -b $(N2N_REV) src ; fi

clean:
	@if [ -d src ] ; then cd src && make clean ; fi

dependencies:
	# NB: only needed when PKGDEPS, PYTHONPKGS is not empty
	@if [ ! -z "$(PKGDEPS)" ] ; then $(SUDO) apt-get install -y $(PKGDEPS) ; fi
	@if [ ! -z "$(PYTHONPKGS)" ] ; then $(SUDO) pip3 install $(PYTHONPKGS) ; fi

disable:
	@( for c in stop disable ; do $(SUDO) systemctl $${c} $(SERVICES) ; done ; true )

enable:
	@( for c in stop disable ; do $(SUDO) systemctl $${c} $(SERVICES) ; done ; true )
	@( for s in $(SERVICES) ; do $(SUDO) install -Dm644 $${s%.*}.service $(LIBSYSTEMD)/$${s%.*}.service ; done ; true )
	@if [ ! -z "$(SERVICES)" ] ; then $(SUDO) systemctl daemon-reload ; fi
	@( for s in $(SERVICES) ; do $(SUDO) systemctl enable $${s%.*} ; done ; true )

install: config
	@$(MAKE) --no-print-directory $(EDGE)
	@$(SUDO) install -Dm644 config/supernodes.list $(SYSCFG)/supernodes.list
	@$(MAKE) --no-print-directory enable

provision:
	@if [ -e $(CONFIG)/$(SN).mav ] ; then \
		$(SUDO) python3 configure.py --mavnet=$(CONFIG)/$(SN).mav --interactive ; \
	else \
		$(SUDO) python3 configure.py --interactive --start ; \
	fi

see:
	cat $(SYSCFG)/edge.conf

test:
	@if [ -e $(SYSCFG)/edge.conf ] ; then \
		DEV=$(shell grep ^-d $(SYSCFG)/edge.conf | cut -f2 -d=) ; \
		ADR := $(shell ip -o -f inet addr show $$DEV | tr -s [:space:] | cut -s -f4 -d' ') ; \
		nmap -sP $$ADR ; \
	fi

uninstall:
	@$(MAKE) --no-print-directory disable
	@( for s in $(SERVICES) ; do $(SUDO) rm $(LIBSYSTEMD)/$${s%.*}.service ; done ; true )
	@if [ ! -z "$(SERVICES)" ] ; then $(SUDO) systemctl daemon-reload ; fi
	$(SUDO) rm -f $(SYSCFG)/edge.conf $(SYSCFG)/supernodes.list

update:
	@cd src && git pull
