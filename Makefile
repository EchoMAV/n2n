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

.PHONY = clean deps install provision uninstall update

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

provision: $(CONFIG)
	python3 configure.py  $(CONFIG)/$(SN).mav $(N2N)/edge.conf

uninstall:
	$(SUDO) systemctl disable edge && $(SUDO) rm -f $(LIBSYSTEMD)/edge.service
	$(SUDO) systemctl daemon-reload
	$(SUDO) rm -f $(N2N)/.* && $(SUDO) rmdir $(N2N)

update:
	@cd src && git pull

