#=============================================================================
#
# libvmod-queryfilter: Makefile.am
#
#=============================================================================

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = src

doc_DATA = README.md LICENSE

if HAVE_MD2MAN
dist_man_MANS = vmod_queryfilter.3

vmod_queryfilter.3: README.md
MAINTAINERCLEANFILES = $(dist_man_MANS)
	${MD2MAN} @top_srcdir@/README.md > vmod_queryfilter.3
endif

# EOF

