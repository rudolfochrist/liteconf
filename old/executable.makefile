# Makefile  -*- mode: makefile-gmake; -*-

include config.mk

PROGRAM = 

LISPSRCS = $(shell find . -name "*.lisp")
ASDSRCS = $(wildcard *.asd)

all: $(PROGRAM)

$(PROGRAM): $(ASDSRCS) $(LISPSRCS) version config.lisp
	-rm -f $(PROGRAM)
	CL_SOURCE_REGISTRY=$(CL_SOURCE_REGISTRY) $(CL) $(CLFLAGS) \
	--load config.lisp \
	--eval '(asdf:load-system "$(PACKAGE_NAME)" :force t)' \
	--eval '(gc :full t)' \
	--eval '(asdf:make "$(PACKAGE_NAME)/executable" :force t)'

check:
	CL_SOURCE_REGISTRY=$(CL_SOURCE_REGISTRY) $(CL) $(CLFLAGS) \
	--load config.lisp \
	--eval '(asdf:test-system "$(PACKAGE_NAME)" :force t)'
clean:
	-rm -f *.fasl **/*.fasl
	-rm -f $(PACKAGE_NAME).info $(PACKAGE_NAME).html
	-rm -f $(PROGRAM)

distclean: clean
	-rm -r config.mk config.status config.lisp

dist: all info
	-rm -f $(PACKAGE_TARNAME).tar.gz
	$(GIT) archive --format tar.gz --prefix $(PACKAGE_TARNAME)/ \
	  -o $(PACKAGE_TARNAME).tar.gz --add-file $(PACKAGE_NAME).info HEAD

distcheck: dist
	$(MKDIR_P) build
	tar xf $(PACKAGE_TARNAME).tar.gz -C build
	cd build/$(PACKAGE_TARNAME) && ./configure --srcdir .
	cd build/$(PACKAGE_TARNAME) && $(MAKE)
	cd build/$(PACKAGE_TARNAME) && $(MAKE) check
	cd build/$(PACKAGE_TARNAME) && $(MAKE) install DESTDIR=_inst
	cd build/$(PACKAGE_TARNAME) && echo "check installtion" && echo "*** Package ready for distribution"
	-rm -rf build

install: all installdirs install-info install-html


uninstall: uninstall-info uninstall-html

installdirs:
	$(MKDIR_P) $(DESTDIR)$(pkgdocdir)
	$(MKDIR_P) $(DESTDIR)$(infodir)

info: $(PACKAGE_NAME).info

$(PACKAGE_NAME).info: documentation/$(PACKAGE_NAME).texi documentation/*.texi
	$(MAKEINFO) $(srcdir)/$<

$(PACKAGE_NAME).html: documentation/$(PACKAGE_NAME).texi documentation/*.texi
	$(MAKEINFO) --html --no-split -o $@ $<

install-info: $(PACKAGE_NAME).info installdirs
	$(INSTALL_DATA) $< $(DESTDIR)$(infodir)/$<
	# run install-info if available
	if $(SHELL) -c 'install-info --version' \
	   >/dev/null 2>&1; then \
	   install-info --dir-file="$(DESTDIR)$(infodir)/dir" \
	                "$(DESTDIR)$(infodir)/$<"; \
	else true; fi

uninstall-info:
	test -f $(DESTDIR)$(infodir)/$(PACKAGE_NAME).info && \
	  rm $(DESTDIR)$(infodir)/$(PACKAGE_NAME).info

install-html: $(PACKAGE_NAME).html installdirs
	$(INSTALL_DATA) $< $(DESTDIR)$(pkgdocdir)/$<

uninstall-html:
	test -d $(DESTDIR)$(pkgdocdir) && rm -rf $(DESTDIR)$(pkgdocdir)


.PHONY: all check clean distclean dist install uninstall installdirs info \
	install-info install-html uninstall-info uninstall-html distcheck
