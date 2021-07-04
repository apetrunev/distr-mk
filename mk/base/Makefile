DEBIAN_VERSION := $(shell . /etc/os-release && echo $$VERSION_CODENAME)
PACKAGES := $(shell sed '/^\#/d' packages/distr)
MANUAL_PACKAGES := $(shell sed '/^\#/d' packages/manual)

.PHONY: packages sourceslist

all: help

help:
	@echo "help: make install"
	@echo "      make sourceslist"
	@echo "      make packages"

sourceslist:
	echo "Copy sources list to /etc/apt"
	test -f /etc/apt/sources.list && mv /etc/apt/sources.list /etc/apt/sources.list.old || true
	cp -v sourceslist/$(DEBIAN_VERSION).sources.list /etc/apt/sources.list
	apt-get -y install curl wget apt-transport-https dirmngr || true
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
	dpkg --add-architecture i386
	apt-get update

packages: sourceslist
	@apt-get -y purge light-locker || true
	@echo "Disable keyboard scroll"
	@sed -i 's/,grp_led:scroll//g' /etc/default/keyboard
	apt-get -y install $(PACKAGES) || true  
	@apt-mark manual $(MANUAL_PACKAGES) || true

install: packages
