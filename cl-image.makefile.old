# Makefile  -*- mode: makefile-gmake; -*-

include config.mk

IMAGE = $(PACKAGE_NAME).image

LISPSRCS = $(shell find . -name "*.lisp")
ASDSRCS = $(wildcard *.asd)

all: $(IMAGE).image

$(IMAGE).image: $(ASDSRCS) $(LISPSRCS) version config.lisp
	-rm -f $(IMAGE).image
	$(CL) $(CLFLAGS) \
	--load config.lisp \
	--eval '(asdf:load-system "$(PACKAGE_NAME)" :force t)' \
	--eval '(gc :full t)' \
	--eval '(asdf:make "$(PACKAGE_NAME)/image")'

check:
	$(CL) $(CLFLAGS) \
	--load config.lisp \
	--eval '(asdf:test-system "$(PACKAGE_NAME)" :force t)'
clean:
	-rm -f *.fasl **/*.fasl
	-rm -f $(PACKAGE_NAME).info
	-rm -f $(IMAGE).image

distclean: clean
	-rm -r config.mk config.status config.lisp

dist:
	-rm -f $(PACKAGE_TARNAME).tar.gz
	$(GIT) archive --format tar.gz --prefix $(PACKAGE_TARNAME)/ \
	  -o $(PACKAGE_TARNAME).tar.gz HEAD

distcheck: dist
	$(MKDIR_P) build
	tar xf $(PACKAGE_TARNAME).tar.gz -C build
	cd build/$(PACKAGE_TARNAME) && ./configure --srcdir .
	cd build/$(PACKAGE_TARNAME) && $(MAKE)
	cd build/$(PACKAGE_TARNAME) && $(MAKE) check
	cd build/$(PACKAGE_TARNAME) && echo "check installation" && echo "*** Package ready for distribution"
	-rm -rf build

info: $(PACKAGE_NAME).info

$(PACKAGE_NAME).info: documentation/$(PACKAGE_NAME).texi documentation/dict.texi
	$(MAKEINFO) $(srcdir)/$<
