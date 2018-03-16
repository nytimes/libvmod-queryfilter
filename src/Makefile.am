#=============================================================================
#
# libvmod-queryfilter: src/Makefile.am
#
#=============================================================================

AM_CPPFLAGS = \
    $(VMOD_INCLUDES) \
    -I@VARNISHSRC@/include \
    -I@VARNISHSRC@/bin/varnishd \
    -I@VARNISHSRC@ \
    -I@top_builddir@/include

vmoddir = @VMOD_DIR@
vmod_LTLIBRARIES = libvmod_queryfilter.la

libvmod_queryfilter_la_LDFLAGS = \
    -module \
    -export-dynamic \
    -avoid-version \
    -shared

libvmod_queryfilter_la_SOURCES = \
	vcc_if.c \
	vcc_if.h \
	vmod_queryfilter.c

if VARNISHSRC_3_X
vcc_if.c vcc_if.h: @top_srcdir@/src/vmod_queryfilter.vcc
	@PYTHON@ @VMODTOOL@ @top_srcdir@/src/vmod_queryfilter.vcc
endif

if VARNISHSRC_4_X
config.h: ../vmod_queryfilter_config.h
	cp ../vmod_queryfilter_config.h config.h

vcc_if.c vcc_if.h: @top_srcdir@/src/vmod_queryfilter4.vcc config.h
	@PYTHON@ @VMODTOOL@ @top_srcdir@/src/vmod_queryfilter4.vcc
endif

VMOD_TESTS = @abs_srcdir@/tests/*.vtc
.PHONY: $(VMOD_TESTS)

@abs_srcdir@/tests/*.vtc:
	@VARNISHTEST@ \
        -Dvarnish_source=@VARNISHSRC@ \
        -Dvarnishd=@VARNISHSRC@/bin/varnishd/varnishd \
        -Dvmod_topbuild=@abs_top_builddir@ $@

check: $(VMOD_TESTS)

EXTRA_DIST = \
	vmod_queryfilter.vcc \
	$(VMOD_TESTS)

CLEANFILES = @builddir@/vcc_if.c @builddir@/vcc_if.h

## EOF

