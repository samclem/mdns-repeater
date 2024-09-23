# Makefile for mdns-repeater

RM = rm -f
CP = cp -p

ZIP_NAME = mdns-repeater-$(HGVERSION)

ZIP_FILES = mdns-repeater	\
			README.txt		\
			LICENSE.txt

HGVERSION=$(shell hg parents --template "{latesttag}.{latesttagdistance}")

CFLAGS=-Wall

CFLAGS_DEBUG=-g

CFLAGS_RELEASE=-Os
LDFLAGS_RELEASE=-s

CFLAGS += $(if $(DEBUG), $(CFLAGS_DEBUG), $(CFLAGS_RELEASE))
LDFLAGS += $(if $(DEBUG), $(LDFLAGS_DEBUG), $(LDFLAGS_RELEASE))

CFLAGS+= -DHGVERSION="\"${HGVERSION}\""

OBJ = mdns-repeater.o

.PHONY: all clean

all: mdns-repeater

mdns-repeater: $(OBJ)
	$(CC) -o $@ $(OBJ)

.PHONY: zip
zip: TMPDIR := $(shell mktemp -d)
zip: mdns-repeater
	mkdir $(TMPDIR)/$(ZIP_NAME)
	cp $(ZIP_FILES) $(TMPDIR)/$(ZIP_NAME)
	-$(RM) $(CURDIR)/$(ZIP_NAME).zip
	cd $(TMPDIR) && zip -r $(CURDIR)/$(ZIP_NAME).zip $(ZIP_NAME)
	-$(RM) -rf $(TMPDIR)

# version checking rules
.PHONY: dummy
_hgversion: dummy
	@echo $(HGVERSION) | cmp -s $@ - || echo $(HGVERSION) > $@

clean:
	-$(RM) *.o
	-$(RM) _hgversion
	-$(RM) mdns-repeater
	-$(RM) mdns-repeater-*.zip

.PHONY: pkg
pkg: mdns-repeater
	$(CP) mdns-repeater pkg/

install: pkg
	cd pkg && ./INSTALL

