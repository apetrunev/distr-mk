DEBIAN_VERSION := $(shell . /etc/os-release && echo $$VERSION_CODENAME)
PAM_D := /etc/pam.d
PAM_UMASK := pam_umask.so
PAM_MKHOMEDIR := pam_mkhomedir.so

all: help

help:
	@echo "help: make install"

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

install:
	apt-get -y install libpam-ldapd || true
	@pam-auth-update || true
	@$(call enablePAM_MKHOMEDIR)
	@$(call enablePAM_UMASK)	
