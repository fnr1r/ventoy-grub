include scripts/here.mk
include $(SCRIPTS_DIR)/shared.mk

BUILDAUX := build-aux

FORMATS := i386-pc i386-efi x86_64-efi aarch64-efi mips64el-efi

.PHONY: all bootstrap build
all: build
bootstrap:
	+bash $(SCRIPTS_DIR)/ovlmake.sh $@ $(MAKE)
build: $(FORMATS)
clean:
	-rm -r dist build
	-sudo rm -rf $(foreach f,$(FORMATS),build-overlay/$f/work/index)
	-rm -rf $(addprefix build-overlay/,$(FORMATS))
	-rm -r build-work
clean-all: clean
	-sudo rm -rf build-overlay/bootstrap/work/index
	-rm -rf build-overlay

$(FORMATS): bootstrap
	+bash $(SCRIPTS_DIR)/ovlmake.sh $@ $(MAKE)
