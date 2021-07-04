include office.links

DOWNLOAD:=/tmp/Libre

LIBREOFFICE:=$(LIBRE7.1)
LIBREOFFICE_LANG:=$(LIBRE7.1_LANG)
LIBREOFFICE_HELP:=$(LIBRE7.1_HELP)
LIBRE_PROGRAM:=/opt/libreoffice7.1/program

all: help 

help:
	@echo "help: make install -- Install working version of Libreoffice"
	@echo "      make clean -- remove $(DOWNLOAD) dir"
	@echo "      make help -- show help"

define xwget
        test -f $(1)/`basename $(2)` || wget -P $(1) $(2)
endef

install: clean
	@echo "Delete default libreoffice"
	@apt-get -y purge $$(dpkg -l | grep libreoffice | awk '{ print $$2 }') || true
	@echo "Make a temp directory $(DOWNLOAD) for LibreOffice download"
	@mkdir -p $(DOWNLOAD)
	@$(call xwget,$(DOWNLOAD),$(LIBREOFFICE))
	@$(call xwget,$(DOWNLOAD),$(LIBREOFFICE_LANG))
	@$(call xwget,$(DOWNLOAD),$(LIBREOFFICE_HELP))
	@cd $(DOWNLOAD) && find ./ -mindepth 1 -maxdepth 1 -type f -exec tar xvzf "{}" \;
	@find $(DOWNLOAD) -mindepth 1 -maxdepth 1 -name "LibreOffice*deb" -exec sh -c "dpkg -i \"{}\"/DEBS/*.deb" \;
	@find $(DOWNLOAD) -mindepth 1 -maxdepth 1 -name "LibreOffice*langpack_ru" -exec sh -c "dpkg -i \"{}\"/DEBS/*.deb" \;
	@find $(DOWNLOAD) -mindepth 1 -maxdepth 1 -name "LibreOffice*helppack_ru" -exec sh -c "dpkg -i \"{}\"/DEBS/*.deb" \;
	@if [ ! -d /usr/local/bin ]; then mkdir -vp /usr/local/bin; else  true; fi
	@if [ -L /usr/local/bin/soffice ]; then rm -vf /usr/local/bin/soffice; else  true; fi
	@cd /usr/local/bin && ln -vs $(LIBRE_PROGRAM)/soffice

clean:
	@echo "Delete old $(DOWNLOAD) dir"
	@sudo rm -vrf $(DOWNLOAD) || true

