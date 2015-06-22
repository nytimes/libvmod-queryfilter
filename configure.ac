## Run autoconf on this file to produce configure.in
#=============================================================================
#
# libvmod-queryfilter/configure.ac: autoconf configuration file
#
#=============================================================================

#-----------------------------
#           Init:
#-----------------------------
AC_PREREQ(2.59)
AC_COPYRIGHT([Copyright (c) 2015 The New York Times Company])
AC_INIT([libvmod-queryfilter], [0.0.4])
AC_CONFIG_AUX_DIR([.])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR(src/vmod_queryfilter.vcc)
AC_CONFIG_HEADERS(config.h)
AC_CANONICAL_SYSTEM
AC_LANG(C)
AC_GNU_SOURCE
AM_INIT_AUTOMAKE([foreign])

#-----------------------------
#       Required Tools:
#-----------------------------
AC_PROG_CC
AC_PROG_CC_STDC
if test "x$ac_cv_prog_cc_c99" = "xno"; then
	AC_MSG_ERROR([Could not find a C99 compatible compiler])
fi
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_LIBTOOL
AC_PROG_MAKE_SET

# Check for rst utilities
AC_CHECK_PROGS(RST2MAN, [rst2man rst2man.py], "no")
if test "x$RST2MAN" = "xno"; then
	AC_MSG_WARN([rst2man not found - not building man pages])
fi
AM_CONDITIONAL(HAVE_RST2MAN, [test "x$RST2MAN" != "xno"])

# Check for pkg-config
PKG_PROG_PKG_CONFIG

# Check for python
AC_CHECK_PROGS(PYTHON,
	[python3 python3.1 python3.2 python2.7 python2.6 python2.5 python2 python],
	[AC_MSG_ERROR(
        [Python is needed to build this vmod. Please install python.])
	])

#-----------------------------
#       Dependencies:
#-----------------------------
AC_HEADER_STDC
AC_CHECK_HEADERS([sys/stdlib.h])

# Locate the varnish source tree
AC_ARG_VAR([VARNISHSRC], [path to Varnish source tree (mandatory)])
if test "x$VARNISHSRC" = "x"; then
	AC_MSG_ERROR([No Varnish source tree specified])
fi
VARNISHSRC=`cd $VARNISHSRC && pwd`
AC_CHECK_FILE([$VARNISHSRC/include/varnishapi.h],
	[],
	[AC_MSG_FAILURE(["$VARNISHSRC" is not a Varnish source directory])]
)

# Check that varnishtest is built in the varnish source directory
AC_CHECK_FILE([$VARNISHSRC/bin/varnishtest/varnishtest],
	[],
	[AC_MSG_FAILURE([No varnish build found in "$VARNISHSRC". \
        Please build your varnish source directory])]
)

# Determine the vmod installation dir
AC_ARG_VAR([VMODDIR], [vmod installation directory @<:@LIBDIR/varnish/vmods@:>@])
if test "x$VMODDIR" = "x"; then
	VMODDIR=`pkg-config --variable=vmoddir varnishapi`
	if test "x$VMODDIR" = "x"; then
		AC_MSG_FAILURE([Please set VMODDIR to the vmod installation path])
	fi
fi

#-----------------------------
#         Metadata:
#-----------------------------
AC_SUBST([PACKAGE_URL],
    ["https://github.com/andrew-canaday/libvmod-queryfilter"])
AC_SUBST([PACKAGE_LICENSE],["Apache"])
AC_SUBST([PACKAGE_VENDOR],["The New York Times Company"])
AC_SUBST([PACKAGE_COPYRIGHT],["copyright 2015 The New York Times Company"])
AC_SUBST([PACKAGE_DESCRIPTION],["Simple Varnish query filter/sort VMOD"])
AC_SUBST([PACKAGE_SUMMARY],["Simple Varnish query filter/sort VMOD"])


#-----------------------------
#          Output:
#-----------------------------
AC_CONFIG_FILES([
	Makefile
	src/Makefile
])
AC_OUTPUT

## EOF

