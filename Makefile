PAM_D:=/etc/pam.d
PAM_UMASK := pam_umask.so
PAM_MKHOMEDIR := pam_mkhomedir.so
DEBIAN_VERSION:=$(shell . /etc/os-release && echo $$VERSION_CODENAME)
# escape hash sign
PACKAGES := $(shell sed '/^\#/d' distr.packages)
MANUAL_PACKAGES := $(shell sed '/^\#/d' manual.packages)

all: help

help:
	@echo "help: make ldap_distr -- Full-fledged distr with ldap authentication"
	@echo "      make distr -- Full-fledged distr"
	@echo "      make packages -- Install basic packages"
	@echo "      make office -- Download Libreoffice from web archive"
	@echo "      make x11vnc -- Enable x11vnc.service"
	@echo "      make sourceslist"
	@echo "      make autoremove"

office:
	./office.mk install

cups-browsed:
	@echo "Disable cups-browsed.service"
	@systemctl stop cups-browsed.service
	@systemctl disable cups-browsed.service
	@systemctl restart cups.service

x11vnc:
	@echo "Enable x11vnc.service"
	@cp x11vnc.service /etc/systemd/system/
	@systemctl daemon-reload
	@systemctl enable x11vnc.service
	@systemctl start x11vnc.service

sourceslist:
	echo "Copy sources list to /etc/apt"
	test -f /etc/apt/sources.list && mv /etc/apt/sources.list /etc/apt/sources.list.old || true
	cp $(DEBIAN_VERSION).sources.list /etc/apt/sources.list
	apt-get -y install curl wget apt-transport-https dirmngr || true
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
	dpkg --add-architecture i386
	apt-get update

define enablePAM_UMASK
	if [ -z "$$(grep -o $(PAM_UMASK) $(PAM_D)/common-session)" ]; then \
		$(eval TMP:=$(shell mktemp)) \
		cp $(PAM_D)/common-session $(PAM_D)/common-session.old; \
		if [ -z "$$(grep -o $(PAM_MKHOMEDIR) $(PAM_D)/common-session)" ]; then \
			awk '{ \
 				if ($$0 ~ /end of pam-auth-update config/) { \
					printf("session optional\t\t\t$(PAM_UMASK) umask=0002\n"); \
					print; \
				} else { \
					print; \
				} \
			      }' $(PAM_D)/common-session > $(TMP); \
			cp $(TMP) $(PAM_D)/common-session; \
			rm $(TMP); \
		else \
			awk '{ \
				if ($$0 ~ /$(PAM_MKHOMEDIR)/) { \
					print; \
					printf("session optional\t\t\t$(PAM_UMASK) umask=0002\n"); \
				} else { \
					print; \
				} \
			     }' $(PAM_D)/common-session > $(TMP); \
			cp $(TMP) $(PAM_D)/common-session; \
			rm $(TMP); \
		fi; \
	else true; fi
endef

# place pam_mkhomedir.so before pam_umask.so
define enablePAM_MKHOMEDIR
	if [ "x$(DEBIAN_VERSION)" = "xstretch" ]; then \
		if [ -z "$$(grep -o $(PAM_MKHOMEDIR) $(PAM_D)/common-session)" ]; then \
			$(eval TMP:=$(shell mktemp)) \
			cp $(PAM_D)/common-session $(PAM_D)/common-session.old; \
			if [ -n "$$(grep -o $(PAM_UMASK) $(PAM_D)/common-session)" ]; then \
				awk '{ \
					if ($$0 ~ /$(PAM_UMASK)/) { \
						printf("session optional\t\t\t$(PAM_MKHOMEDIR)\n"); \
						print; \
					} else { \
						print; \
					} \
			      	     }' $(PAM_D)/common-session > $(TMP); \
				cp $(TMP) $(PAM_D)/common-session; \
				rm $(TMP); \
			else \
				awk '{ \
					if ($$0 ~ /end of pam-auth-update config/) { \
						printf("session optional\t\t\t$(PAM_MKHOMEDIR)\n"); \
						print; \
					} else { \
						print; \
					} \
			     	     }' $(PAM_D)/common-session > $(TMP); \
				cp $(TMP) $(PAM_D)/common-session; \
				rm $(TMP); \
			fi; \
		else true; fi \
	else true; fi
endef

packages: sourceslist
	@apt-get -y purge light-locker || true
	@echo "Disable keyboard scroll"
	@sed -i 's/,grp_led:scroll//g' /etc/default/keyboard
	apt-get -y install $(PACKAGES) || true	
	@apt-mark manual $(MANUAL_PACKAGES) || true

autoremove:
	@echo "Delete unused packages"
	@apt-get -y autoremove || true

distr: packages x11vnc cups-browsed office autoremove  

ldap_auth:
	apt-get -y install libpam-ldapd || true
	@pam-auth-update || true
	@$(call enablePAM_MKHOMEDIR)
	@$(call enablePAM_UMASK)

ldap_distr: packages ldap_auth x11vnc cups-browsed office autoremove 
	
