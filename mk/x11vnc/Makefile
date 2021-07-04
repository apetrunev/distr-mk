CUR_DIR := $(shell pwd)
SYSTEMD_DIR := /etc/systemd/system
X11VNC_SERVICE := x11vnc.service

all: help

help:
	@echo "help: make install"

install:
	@echo "Enable $(X11VNC_SERVICE)"
	@cp -v $(X11VNC_SERVICE) /etc/systemd/system/
	@systemctl daemon-reload
	@systemctl enable $(X11VNC_SERVICE)
	@systemctl start $(X11VNC_SERVICE)

