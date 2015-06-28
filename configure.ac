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
AC_CANONICAL_SYSTEM
AC_LANG(C)
AC_GNU_SOURCE
AM_INIT_AUTOMAKE([foreign])

#-----------------------------
#         Build Tools:
#-----------------------------
AC_PROG_CC
AC_PROG_CC_C99
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
QUERYFILTER_VARNISH

#--------------------------
#    Optional Features:    
#--------------------------
# Check for query-arrays:
AC_ARG_ENABLE([query-arrays],
    AS_HELP_STRING(
        [--enable-query-arrays],
        [Turn verbose assertions on for tests]))

# If set, extend CFLAGS with verbose assertions
if test "x$enable_query_arrays" = "xyes"; then
    vmod_queryfilter_arrays_enabled=1
else
    vmod_queryfilter_arrays_enabled=0
fi

AC_DEFINE_UNQUOTED(
    [VMOD_QUERYFILTER_ARRAYS_ENABLED],
    [$vmod_queryfilter_arrays_enabled],
    [If true, permit php-style query array parameters])

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
AC_CONFIG_HEADERS(vmod_queryfilter_config.h)
AC_CONFIG_FILES([
	Makefile
	src/Makefile
])
AC_OUTPUT

## EOF

