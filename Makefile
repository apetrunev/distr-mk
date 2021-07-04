CUR_DIR := $(shell pwd)

all: help

help:
	@echo "help: make ldap_distr -- Full-fledged distr with ldap authentication"
	@echo "      make distr -- Full-fledged distr"
	@echo "      make packages -- Install basic packages"
	@echo "      make office -- Download Libreoffice from web archive"
	@echo "      make x11vnc -- Enable x11vnc.service"
	@echo "      make sourceslist"
	@echo "      make autoremove"

packages:
	make -C $(CUR_DIR)/mk/base install

sourceslist:
	make -C $(CUR_DIR)/mk/base sourceslist

office:
	make -C $(CUR_DIR)/mk/office install	

cups:
	make -C $(CUR_DIR)/mk/cups install

x11vnc:
	make -C $(CUR_DIR)/mk/x11vnc install

ldap:
	make -C $(CUR_DIR)/mk/ldap install

autoremove:
	@apt-get -y autoremove || true

distr: packages x11vnc cups office autoremove  
ldap_distr: packages ldap x11vnc cups office autoremove 
