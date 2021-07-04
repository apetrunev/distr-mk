all: help

help:
	@echo "help: make install"

install:
	@systemctl stop cups-browsed.service
	@systemctl disable cups-browsed.service
	@systemctl restart cups.service
