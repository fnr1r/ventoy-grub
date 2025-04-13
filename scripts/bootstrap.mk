HERE := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
include $(HERE)/here.mk

.PHONY: all bootstrap
all: bootstrap
bootstrap: configure

configure:
	./bootstrap
