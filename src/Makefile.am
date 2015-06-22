#=============================================================================
#
# libvmod-queryfilter: src/Makefile.am
#
#=============================================================================

AM_CPPFLAGS = \
    -I@VARNISHSRC@/include \
    -I@VARNISHSRC@

vmoddir = @VMODDIR@
vmod_LTLIBRARIES = libvmod_queryfilter.la

libvmod_queryfilter_la_LDFLAGS = -module -export-dynamic -avoid-version -shared

libvmod_queryfilter_la_SOURCES = \
	vcc_if.c \
	vcc_if.h \
	vmod_queryfilter.c

vcc_if.c vcc_if.h: \
    @VARNISHSRC@/lib/libvmod_std/vmod.py \
        @top_srcdir@/src/vmod_queryfilter.vcc
	@PYTHON@ @VARNISHSRC@/lib/libvmod_std/vmod.py \
        @top_srcdir@/src/vmod_queryfilter.vcc

VMOD_TESTS = @abs_srcdir@/tests/*.vtc
.PHONY: $(VMOD_TESTS)

tests/*.vtc:
	@VARNISHSRC@/bin/varnishtest/varnishtest \
        -Dvarnish_source=@VARNISHSRC@ \
        -Dvarnishd=@VARNISHSRC@/bin/varnishd/varnishd \
        -Dvmod_topbuild=@abs_top_builddir@ $@

check: $(VMOD_TESTS)

EXTRA_DIST = \
	vmod_queryfilter.vcc \
	$(VMOD_TESTS)

CLEANFILES = @builddir@/vcc_if.c @builddir@/vcc_if.h

## EOF

